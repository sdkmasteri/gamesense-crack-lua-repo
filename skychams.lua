local ffi = require("ffi")
local clipboard = require("gamesense/clipboard")
local fsystem = {}
local iinput = {}
local mattable = database.read("skychams::mattable", mattable) or {}
local menu = {}
do
    local filesystem_interface = ffi.cast(ffi.typeof("void***"), client.create_interface("filesystem_stdio.dll", "VFileSystem017"))
    local filesystem_create_directories = ffi.cast("void (__thiscall*)(void*, const char*, const char*)", filesystem_interface[0][22])
    local filesystem_find = ffi.cast("const char* (__thiscall*)(void*, const char*, int*)", filesystem_interface[0][32])
    local filesystem_findnext = ffi.cast("const char* (__thiscall*)(void*, int)", filesystem_interface[0][33])

    fsystem.create_directories = function(file, path_id)
        filesystem_create_directories(filesystem_interface, file, path_id)
    end

    fsystem.find_first = function(file)
        local int_ptr = ffi.new("int[1]")
        local res = filesystem_find(filesystem_interface, file, int_ptr)
        if res == ffi.NULL then
            return nil
        end

        return int_ptr, ffi.string(res)
    end

    fsystem.find_next = function(handle)
        local file = filesystem_findnext(filesystem_interface, handle[0])
        if file == ffi.NULL then return nil end
        return ffi.string(file)
    end

    fsystem.get_directory_files = function(path)
        local files = {}

        local handle, file = fsystem.find_first(path .. "/*")
        while file do
            if string.sub(file, 1, 1) ~= "." then
                files[#files + 1] = file
            end
            file = fsystem.find_next(handle)
        end
        return files
    end

    local address = ffi.cast("void*", ffi.cast("char*", client.find_signature("client.dll", "\xB9\xCC\xCC\xCC\xCC\x8B\x40\x38\xFF\xD0\x84\xC0\x0F\x85")) + 0x1);
    local iface = ffi.cast("uintptr_t***", address)[0];

    local native_CAM_IsThirdPerson = ffi.cast("bool(__thiscall*)(void*, int nSlot)", iface[0][32]);

    function iinput.is_third_person(slot)
        slot = slot or -1;

        return native_CAM_IsThirdPerson(iface, slot);
    end

    local matpath = "csgo/materials/"
    local texturetamplate = [[
        "UnlitTwoTexture"
        {
            "$moondome" "1"
            "$basetexture" "vgui/white"
            "$basetexturetransform" "center .4 .2 scale 100 99 rotate 1 translate 0 0"
            "$cubeparallax" "0.00005"
            "$texture2" "%s"
        }
    ]]
    materialsystem.create_material = function(name, matstr)
        writefile(matpath..name..".vmt", matstr)
        return materialsystem.find_material(name, true)
    end

    materialsystem.create_parralax = function(name, basetexture)
        return materialsystem.create_material(name, texturetamplate:format(basetexture))
    end

    local function get_weapon_viewmodel(me, wpn, is_third_person)
        if wpn == nil then
            return;
        end

        if is_third_person then
            return entity.get_prop(wpn, "m_hWeaponWorldModel");
        end

        return entity.get_prop(me, "m_hViewModel[0]");
    end

    materialsystem.get_weapon_materials = function(me, wpn, is_third_person)
        local entindex = get_weapon_viewmodel(me, wpn, is_third_person);

        if entindex == nil then
            return { };
        end

        return materialsystem.get_model_materials(entindex);
    end
    mattable.target = {"Local Player", "Weapon Model", "View Model"}
    mattable.matsv  = mattable.matsv or {}
    if mattable["Local Player"] == nil then
        for i = 1, #mattable.target do
            mattable[mattable.target[i]] = {enable = false}
        end
    end
    menu.matsvi = database.read("skychams::matsvi") or {}
    menu.target = ui.new_listbox("LUA", "A", "Options", mattable.target)
    menu.matsv  = ui.new_listbox("LUA", "A", "Materials", menu.matsvi)
    menu.enable = ui.new_checkbox("LUA", "A", "Enable")
    menu.change = ui.new_button("LUA", "A", "Change", function()end)
    menu.back   = ui.new_button("LUA", "A", "Back", function()end)
    menu.file   = ui.new_textbox("LUA", "B", "File")
    menu.add    = ui.new_button("LUA", "B", "Add", function()end)
    menu.clip   = ui.new_button("LUA", "B", "From Clipboard", function()end)
    local function changehandle()
        if (not menu.is_changing) then
            ui.set_visible(menu.target, false)
            ui.set_visible(menu.matsv, true)
            ui.set_visible(menu.back, true)
            ui.set_visible(menu.enable, false)
            menu.is_changing = true
        else
            mattable[mattable.target[ui.get(menu.target)+1]].mat = mattable.matsv[ui.get(menu.matsv)+1]
        end
    end
    local function backhandle(id)
        ui.set_visible(id, false)
        ui.set_visible(menu.matsv, false)
        ui.set_visible(menu.target, true)
        ui.set_visible(menu.enable, true)
        menu.is_changing = false
    end
    local function targethandle(id)
        ui.set(menu.enable, mattable[mattable.target[ui.get(id)+1]].enable)
    end
    local function enalbehandle(id)
        mattable[mattable.target[ui.get(menu.target)+1]].enable = ui.get(id)
        if not ui.get(id) then materialsystem._set_material(mattable.target[ui.get(menu.target)+1]) end
    end
    local function addhandle()
        local name = ui.get(menu.file)
        if not fsystem.find_first('materials/'..name..'.vtf') then
            client.error_log(string.format("no such material: %s", matpath..name))
            goto erase
        end
        mattable.matsv[#mattable.matsv+1] = materialsystem.create_parralax(name.."_parallax", name)
        menu.matsvi[#menu.matsvi+1] = name
        ui.update(menu.matsv, menu.matsvi)
        ::erase::
        ui.set(menu.file, "")
    end
    local function cliphandle()
        ui.set(menu.file, clipboard.get())
    end
    ui.set_visible(menu.matsv, false)
    ui.set_visible(menu.back, false)
    ui.set_callback(menu.target, targethandle)
    ui.set_callback(menu.enable, enalbehandle)
    ui.set_callback(menu.change, changehandle)
    ui.set_callback(menu.back, backhandle)
    ui.set_callback(menu.add, addhandle)
    ui.set_callback(menu.clip, cliphandle)
    if (#menu.matsvi > 0) then
        for i = 1, #menu.matsvi do
            mattable.matsv[i] = materialsystem.find_material(menu.matsvi[i]..'_parallax', true)
        end
    end
end
materialsystem._set_material = function(id)
    local lplayer = entity.get_local_player()
    if lplayer == nil then return end
    local wp = entity.get_player_weapon(lplayer)
    local is_tp = iinput.is_third_person()
    if id then
        if id == "Local Player" then
            local lmats = materialsystem.get_model_materials(lplayer)
            for i = 1, #lmats do
                lmats[i]:reload()
            end
        elseif id == "Weapon Model" then
            local lmats = materialsystem.get_weapon_materials(lplayer, wp, is_tp)
            for i = 1, #lmats do
                lmats[i]:reload()
            end
        elseif id == "View Model" then
            local lmats = materialsystem.get_weapon_materials(lplayer, wp, is_tp)
            for i = 1, #lmats do
                lmats[i]:reload()
            end
        end
    end
    if is_tp then
        if mattable["Local Player"].enable then
            local lmats = materialsystem.get_model_materials(lplayer)
            for i = 1, #lmats do
                materialsystem.override_material(lmats[i], mattable["Local Player"].mat)
            end
        end
        if mattable["Weapon Model"].enable then
            local lmats = materialsystem.get_weapon_materials(lplayer, wp, is_tp)
            for i = 1, #lmats do
                materialsystem.override_material(lmats[i], mattable["Weapon Model"].mat)
            end
        end
    else 
        if mattable["View Model"].enable then
            local lmats = materialsystem.get_weapon_materials(lplayer, wp, is_tp)
            for i = 1, #lmats do
                materialsystem.override_material(lmats[i], mattable["View Model"].mat)
            end
        end
    end
end
client.set_event_callback("pre_render", materialsystem._set_material)

defer(function()
    database.write("skychams::mattable", mattable)
    database.write("skychams::matsvi", menu.matsvi)
end)
