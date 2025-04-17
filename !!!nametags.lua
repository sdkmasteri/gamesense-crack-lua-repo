local ffi = require("ffi")
local inspect = require("gamesense/inspect")
reinterpret_cast = function(addr, typestring)
    return function(...) return ffi.cast(typestring, client.find_signature("engine.dll", "\xFF\xE1"))(addr, ...) end
end
ffi.cdef[[
    typedef int BOOL;
    typedef void* LPVOID;
    typedef unsigned long DWORD;
    typedef DWORD* PDWORD;
    typedef unsigned long ULONG_PTR;
    typedef ULONG_PTR SIZE_T;
    enum ClientFrameStage_t {
        FRAME_UNDEFINED = -1,
        FRAME_START,
        FRAME_NET_UPDATE_START,
        FRAME_NET_UPDATE_POSTDATAUPDATE_START,
        FRAME_NET_UPDATE_POSTDATAUPDATE_END,
        FRAME_NET_UPDATE_END,
        FRAME_RENDER_START,
        FRAME_RENDER_END
    };
    BOOL VirtualProtect(LPVOID lpAddress, SIZE_T dwSize, DWORD  flNewProtect, PDWORD lpflOldProtect);
    LPVOID VirtualAlloc(LPVOID lpAddress, SIZE_T dwSize, DWORD  flAllocationType, DWORD  flProtect);
]]
local get_pattern = {
    GetModuleHandlePtr = ffi.cast("void***", ffi.cast("uint32_t", client.find_signature("engine.dll", "\xFF\x15\xCC\xCC\xCC\xCC\x85\xC0\x74\x0B")) + 2)[0][0],
    GetProcAddressPtr = ffi.cast("void***", ffi.cast("uint32_t", client.find_signature("engine.dll", "\xFF\x15\xCC\xCC\xCC\xCC\xA3\xCC\xCC\xCC\xCC\xEB\x05")) + 2)[0][0],
    reinterpret_cast = function(addr, typestring)
        return function(...) return ffi.cast(typestring, client.find_signature("engine.dll", "\xFF\xE1"))(addr, ...) end
    end,
}

do
    get_pattern.fnGetModuleHandle = get_pattern.reinterpret_cast(get_pattern.GetModuleHandlePtr, "void*(__thiscall*)(void*, const char*)")
    get_pattern.fnGetProcAddress = get_pattern.reinterpret_cast(get_pattern.GetProcAddressPtr, "void*(__thiscall*)(void*, void*, const char*)")
    get_pattern.GetModuleHandle = get_pattern.fnGetModuleHandle
    get_pattern.GetProcAddress = get_pattern.fnGetProcAddress

    get_pattern.lib = { kernel32 = get_pattern.GetModuleHandle("kernel32.dll") }
    get_pattern.export = {
        kernel32 = {
            VirtualProtect = get_pattern.reinterpret_cast(get_pattern.GetProcAddress(get_pattern.lib.kernel32, "VirtualProtect"), "BOOL(__thiscall*)(void*, LPVOID, SIZE_T, DWORD, PDWORD)"),
            VirtualAlloc = get_pattern.reinterpret_cast(get_pattern.GetProcAddress(get_pattern.lib.kernel32, "VirtualAlloc"), "LPVOID(__thiscall*)(void*, LPVOID, SIZE_T, DWORD, DWORD)"),
        }
    }
end
local hook = {all = {}}
do
    hook.new = function(vtable)
        local chook = {
            data = {},
            ogfunc = {},
            oldProto = ffi.new("DWORD[1]"),
            vtable = vtable,
        }
        chook.data.hook = function(typestr, ind, __func, len)
            if len < 5 then return 0 end
            chook.ogfunc[ind] = {vtable[ind], len}
            get_pattern.export.kernel32.VirtualProtect(vtable + ind, len, 0x40, chook.oldProto)
            vtable[ind] = ffi.cast("intptr_t", ffi.cast(typestr, __func))
            get_pattern.export.kernel32.VirtualProtect(vtable + ind, len, chook.oldProto[0], chook.oldProto)
            return ffi.cast(typestr, chook.ogfunc[ind][1])
        end
        chook.data.unhook = function(ind)
            get_pattern.export.kernel32.VirtualProtect(chook.vtable + ind, chook.ogfunc[ind][2], 0x40, chook.oldProto)

            local alloc_addr = ffi.cast("intptr_t", get_pattern.export.kernel32.VirtualAlloc(nil, 5, 0x1000, 0x40))
            local trampoline_bytes = ffi.new("uint8_t[?]", 5, 0x90)
    
            trampoline_bytes[0] = 0xE9
            ffi.cast("int32_t*", trampoline_bytes + 1)[0] = chook.ogfunc[ind][1] - tonumber(alloc_addr) - 5
    
            ffi.copy(ffi.cast("void*", alloc_addr), trampoline_bytes, chook.ogfunc[ind][2])
            chook.vtable[ind] = ffi.cast("intptr_t", alloc_addr)
            get_pattern.export.kernel32.VirtualProtect(chook.vtable + ind, chook.ogfunc[ind][2], chook.oldProto[0], chook.oldProto)
            chook.ogfunc[ind] = nil
        end
        chook.data.unhook_all = function()
            for ind, _ in pairs(chook.ogfunc) do
                chook.data.unhook(ind)
            end
        end
        table.insert(hook.all, chook.data.unhook_all)
        return chook.data
    end
end

local vtbl = ffi.cast("intptr_t**", client.create_interface("client.dll", "VClient018"))[0]

local skinref = ui.reference('SKINS', 'Weapon skin', 'Skin')

ui.new_label("Skins", "Weapon skin", "NameTag")
local nametag = ui.new_textbox("Skins", "Weapon skin", "NameTag")
local allweapons = {}
local lastweapon = nil
origframe = nil

local function applytag(weapon)
    if string.len(ui.get(nametag)) < 1 then return end
    local wname = entity.get_classname(weapon)
    if string.find(wname, "Grenade") or wname == "CFlashbang" then return end
    local defindex = entity.get_prop(weapon, "m_iItemDefinitionIndex")
    entity.set_prop(weapon, "m_szCustomName", allweapons[defindex])
end

local function test(thisptr, stage)
    while stage == ffi.C.FRAME_NET_UPDATE_POSTDATAUPDATE_START do
        local lplayer = entity.get_local_player()
        if lplayer == nil or not entity.is_alive(lplayer) then break end
        local weapon = entity.get_player_weapon(lplayer)
        if weapon == nil then break end
        applytag(weapon)
        break
    end
    origframe(thisptr, stage)
end

local hoknt = hook.new(vtbl)
origframe = hoknt.hook("void*(__thiscall*)(void*, int)", 37, test, 5)
client.set_event_callback("item_equip", function(e)
    local lplayer = entity.get_local_player()
    if client.userid_to_entindex(e.userid) ~= lplayer then return end
    local weapon = entity.get_player_weapon(lplayer)
    local wname = entity.get_classname(weapon)
    if string.find(wname, "Grenade") or wname == "CFlashbang" then return end
    if allweapons[e.defindex] == nil then
        allweapons[e.defindex] = ""
    end
    if lastweapon ~= nil then
        allweapons[lastweapon] = ui.get(nametag)
    end
    ui.set(nametag, allweapons[e.defindex])
    lastweapon = e.defindex
end)
client.set_event_callback("shutdown", function()
    for _, unhook_all in ipairs(hook.all) do
        unhook_all()
    end
end)