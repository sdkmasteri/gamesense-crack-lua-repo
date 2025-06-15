local ffi       = require("ffi")
local vector    = require("vector")

-- @part 1: https://github.com/sdkmasteri/gamesense-crack-lua-repo/blob/main/Hide%20tabs.lua
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


-- @part 2: unlock menu minsize
local minw = ffi.cast("int*", 0x434799C8)
local minh = ffi.cast("int*", 0x434799CC)
local oldminw, oldminh;
local function set_minsize(w, h)
    oldminw = minw[0]
    oldminh = minh[0]
    minw[0] = w
    minh[0] = h
end
set_minsize(180, 130)


-- @part 3: fix tab icons
local menuh_ptr = ffi.cast("int*", 0x434799C4)
local menuact_ptr = ffi.cast("char*", 0x434799E0)

local function tabicons_fix()
    if menuact_ptr[0] == 0x00 then return end
    local menuh = menuh_ptr[0]
    for i=0, #tabs do
        print(menuh)
        if tabs[i].pos.y + tabs[i].size.y > menuh then
            tabs[i].enabled[0] = 0x00
        else
            tabs[i].enabled[0] = 0x01
        end
    end
end
client.set_event_callback("paint_ui", tabicons_fix)


-- @part 4: defer and undo changes
local menuw_ptr = ffi.cast("int*", 0x434799C0)
local function undo()
    if menuw_ptr[0] < oldminw then menuw_ptr[0] = oldminw end
    if menuh_ptr[0] < oldminh then menuh_ptr[0] = oldminh end
    set_minsize(oldminw, oldminh)
    tabicons_fix()
end
defer(undo)