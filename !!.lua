local luabox = ui.reference("Config", "Lua", "Scripts")
local check = ui.reference("Config", "Lua", "Load on startup")
local loadb = ui.reference("Config", "Lua", "Load script")
local loadc = ui.reference("Config", "Lua", "Unload script")
local luat = {}
local cfgs = database.read("luacfgs") or {}
local cfgnames = {}
do
    if cfgs ~= nil then
        for key, _ in pairs(cfgs) do
            table.insert(cfgnames, key)
        end
    end
end
local b = ui.new_listbox("Config", "Lua", "Scripts", cfgnames)
local selfpos = ui.get(luabox)

local maxluas = database.read("maxluas")

if maxluas == nil then
    local index = 0
    local prev, next = -1, 0
    while prev < next do
        index = index == selfpos and index + 1 or index
        ui.set(luabox, index)
        prev = ui.get(luabox)
        index = index + 1
        ui.set(luabox, index)
        next = ui.get(luabox)
    end
    ui.set(luabox, selfpos)
    database.write("maxluas", index - 1) 
end
function luat:is_in(val)
    for _, v in pairs(self) do
        if v == val then return true end
    end
    return false
end
local function get_activity()
    local prev, nex = -1, 0
    local index = 0
    local n = 2147483648
    while index < maxluas do
        if index == selfpos then index = index + 1 end
        ui.set(luabox, index)
        prev = ui.get(luabox)
        if prev == nex then
            ui.set(luabox, -n + index)
            prev = ui.get(luabox)
            if prev < 0 then
                prev = n + prev
                if not luat:is_in(prev) then table.insert(luat, prev) end
            end
        end
        index = index + 1 
        ui.set(luabox, index)
        nex = ui.get(luabox)
        if nex == prev then
            ui.set(luabox, -n + index)
            nex = ui.get(luabox)
            if nex < 0 then
                nex = n + nex
                if not luat:is_in(nex) then table.insert(luat, nex) end
            end
        end
        --index = index + 1 
    end
    ui.set(luabox, selfpos)
end
--print(maxluas)
local cfgname = ui.new_textbox("Config", "Lua", "Name")
local b_create = ui.new_button("Config", "Lua", "Create", function()
    local cname = ui.get(cfgname)
    get_activity()
    cfgs[cname] = luat
    database.write("luacfgs", cfgs)
end)
local b_load = ui.new_button("Config", "Lua", "Load", function()
end)
local b_save = ui.new_button("Config", "Lua", "Save", function()
end)
local b_delete = ui.new_button("Config", "Lua", "Delete", function()
end)