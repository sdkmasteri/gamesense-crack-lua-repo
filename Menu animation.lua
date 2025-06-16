local ffi       = require("ffi")
local vector    = require("vector")

local base = ffi.cast("int*", 0x43479A04)
local rclass = ffi.cast("int*", ffi.cast("int*", 0x43479A00)[0]) -- rage tab class 4 bytes bellow other tabs base

local tabs = { [0] = {} }

tabs[0].enabled = ffi.cast("char*", rclass[0] + 0x15)
tabs[0].pos     = vector(ffi.cast("int*", rclass[0] + 0x20)[0], ffi.cast("int*", rclass[0] + 0x24)[0])
tabs[0].size    = vector(ffi.cast("int*", rclass[0] + 0x28)[0], ffi.cast("int*", rclass[0] + 0x2C)[0])
for i=1, 8 do
    local tabclass  = ffi.cast("int*", base[0] - (0x20 - 0x4*(i-1)))
    tabs[i]         = {}
    tabs[i].enabled = ffi.cast("char*", tabclass[0] + 0x15)
    tabs[i].pos     = vector(ffi.cast("int*", tabclass[0] + 0x20)[0], ffi.cast("int*", tabclass[0] + 0x24)[0])
    tabs[i].size    = vector(ffi.cast("int*", tabclass[0] + 0x28)[0], ffi.cast("int*", tabclass[0] + 0x2C)[0])
end


local minw = ffi.cast("int*", 0x434799C8)
local minh = ffi.cast("int*", 0x434799CC)
local oldminw, oldminh;
local function set_minsize(w, h)
    if oldminw == nil or oldminh == nil then
        oldminw = minw[0]
        oldminh = minh[0]
    end
    minw[0] = w
    minh[0] = h
end
set_minsize(560, 660)
local menux_ptr = ffi.cast("int*", 0x434799B8)
local menuy_ptr = ffi.cast("int*", 0x434799BC)
local function set_pos(x, y)
    menux_ptr[0] = x
    menuy_ptr[0] = y
end

local menuh_ptr = ffi.cast("int*", 0x434799C4)
local menuw_ptr = ffi.cast("int*", 0x434799C0)
local menuact_ptr = ffi.cast("char*", 0x434799E0)
local menu_fademode = ffi.cast("int*", 0x43479A38)

local function set_size(w, h)
    menuw_ptr[0] = w
    menuh_ptr[0] = h
end

local function tabicons_fix(force)
    if menuact_ptr[0] == 0x00 then return end
    local menuh = menuh_ptr[0]
    for i=0, #tabs do
        if tabs[i].pos.y + tabs[i].size.y > menuh then
            tabs[i].enabled[0] = 0x00
        else
            tabs[i].enabled[0] = force
        end
    end
end

local style = ui.new_combobox("Config", "Presets", "Anim Style", {"Minimize", "Сollapse"})
local speed = ui.new_slider("Config", "Presets", "Anim Speed", 150, 1500, 150, true, "ms", 1, {[150] = "Default"})
local fade_speed = ffi.cast("float*", 0x4346F920)

local function set_speed()
    fade_speed[0] = ui.get(speed)
end

ui.set_callback(speed, set_speed)

local csize = vector(menuw_ptr[0], menuh_ptr[0])
local cpos = vector(menux_ptr[0], menuy_ptr[0])
local cscreen = vector(client.screen_size())
local menu_fade = ffi.cast("float*", 0x43479A5C)
local lmode = 0
local function main()
    local mode = menu_fademode[0]
    if mode == 0 and menuact_ptr[0] > 0 and lmode == 0 then
        csize = vector(menuw_ptr[0], menuh_ptr[0])
        cpos = vector(menux_ptr[0], menuy_ptr[0])
        set_minsize(oldminw, oldminh)
        tabicons_fix(0x01)
        return
    elseif lmode ~= 0 then
        set_size(csize:unpack())
        set_pos(cpos:unpack())
    end
    lmode = mode
    local fade = menu_fade[0]
    set_minsize(0, 0)
    set_size(csize.x*fade, csize.y*fade)
    if ui.get(style) == "Сollapse" then
        set_pos(cpos.x + (((cpos.x+csize.x > cscreen.x and cpos.x or cpos.x < 0 and -cpos.x) or cpos.x) * (4 - fade*4)), cpos.y + (((cpos.y+csize.y > cscreen.y and cpos.y*0.2 or cpos.y < 0 and -cpos.y) or cpos.y) * (3 - fade*3)))
    end
    tabicons_fix(0x00)
end
client.set_event_callback("paint_ui", main)


defer(function() set_minsize(oldminw, oldminh) end)