local ffi = require("ffi")
local nopt = ffi.new("char[3]", 0x90, 0x90, 0x90)
local function nop(src)
    ffi.copy(src, nopt, 3)
end
function in_table(tbl, val)
    for _, v in pairs(tbl) do
        if v == val then return true end
    end
    return false
end
local ognamebytes  = ffi.new("char[7]")
local ogborderbytes = ffi.new("char[3]")
local oggripbytes   = ffi.new("char[3]")

local borkennamebytes   = ffi.new("char[7]")

borkennamebytes[0] = 0x8B
borkennamebytes[1] = 0x35
borkennamebytes[2] = 0xB0
borkennamebytes[3] = 0x8F
borkennamebytes[4] = 0x46
borkennamebytes[5] = 0x43
borkennamebytes[6] = 0x90

local namenop = ffi.cast("char*", 0x433AE988)
local bordernop = ffi.cast("char*", 0x4334AF42)
local gripnop = ffi.cast("char*", 0x433AEA18)

ffi.copy(ognamebytes, namenop, 7)
ffi.copy(ogborderbytes, bordernop, 3)
ffi.copy(oggripbytes, gripnop, 3)

local multik = ui.new_multiselect("LUA", "B", "Force Child Color", {"Name", "Border", "Size Grip"})
local wasacitve = {}
ui.new_button("LUA", "B", "Apply", function()

    local toforce = ui.get(multik)

    if in_table(toforce, "Name") then
        ffi.copy(namenop, borkennamebytes, 7)
        wasacitve[1] = true
    elseif wasacitve[1] then
        ffi.copy(namenop, ognamebytes, 7)
        wasacitve[1] = false
    end
    if in_table(toforce, "Border") then
        nop(bordernop)
        wasacitve[2] = true
    elseif wasacitve[2] then
        ffi.copy(bordernop, ogborderbytes, 3)
        wasacitve[2] = false
    end
    if in_table(toforce, "Size Grip") then
        nop(gripnop)
        wasacitve[3] = true
    elseif wasacitve[3] then
        ffi.copy(gripnop, oggripbytes, 3)
        wasacitve[3] = false
    end
end)

defer(function()

    if wasacitve[1] then
        ffi.copy(namenop, ognamebytes, 7)
    end
    if wasacitve[2] then
        ffi.copy(bordernop, ogborderbytes, 3)
    end
    if wasacitve[3] then
        ffi.copy(gripnop, oggripbytes, 3)
    end
end)