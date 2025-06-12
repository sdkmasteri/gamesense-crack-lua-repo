-- Hide tabs from left side panel and disables render tab entire ui (childs e.g)

local ffi = require("ffi")

local base = ffi.cast("int*", 0x43479A04)
local rbase = ffi.cast("int*", 0x43479A00) -- rage tab class 4 bytes bellow other tabs base

local tabs = {}
local vals = {}
--do not add lua tab, cuz you will eventually brick menu))
local tochange = {"Rage", "AA", "Legit", "Visuals", "Misc", "Skins", "Plist", "Config"}

tabs[0] = ffi.cast("char*", ffi.cast("int*", rbase[0])[0] + 0x15)

for i=1, #tochange do
    local tabclass = ffi.cast("int*", base[0] - (0x20 - 0x4*(i-1)))
    tabs[i] = ffi.cast("char*", tabclass[0] + 0x15)
    vals[i] = tabs[i][0] == 0x01 and true or false
    print(vals[i])
end

local disablebox    = ui.new_listbox("LUA", "A", "Disable tabs", tochange) 
local checkbox      = ui.new_checkbox("LUA", "A", "Active")

ui.set_callback(disablebox, function(id)
    local choosen = ui.get(id)
    ui.set(checkbox, vals[choosen])
end)

local function changevisibl(index, bool)
    tabs[index][0] = bool and 0x01 or 0x00
    vals[index] = bool
end

ui.set_callback(checkbox, function(id)
    local current = ui.get(disablebox)
    changevisibl(current, ui.get(id))
end)