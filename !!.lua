--credits: @sakenzo1337
local luabox = ui.reference("Config", "Lua", "Scripts")
local check = ui.reference("Config", "Lua", "Load on startup")
local loadb = ui.reference("Config", "Lua", "Load script")
local loadc = ui.reference("Config", "Lua", "Unload script")
local inspect = require("gamesense/inspect")
local luat = {}
local cfgs = database.read("luacfgs") or {}
local toload = database.read("88821:333333")
local cfgnames = {}
local n = 2147483648
if toload ~= nil and #toload > 0 then
    print("agusha")
    print(inspect(toload))
    ui.set(luabox, toload[1])
    table.remove(toload)
    --ui.set(loadb)
    client.reload_active_scripts()
end
do
    if cfgs ~= nil then
        for key, _ in pairs(cfgs) do
            table.insert(cfgnames, key)
        end
    end
end
local cfglistbox = ui.new_listbox("Config", "Lua", "Scripts", cfgnames)
local selfpos = ui.get(luabox)
local maxluas = database.read("maxluas")

if maxluas == nil then
    print("maxluas nil")
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
    ui.set(luabox, -n + selfpos)
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
    ui.set(luabox, -n + selfpos)
    print(inspect(luat))
end


--print(maxluas)
local cfgname = ui.new_textbox("Config", "Lua", "Name")
ui.set_callback(cfglistbox, function()
    local current_name = cfgnames[ui.get(cfglistbox) + 1]
    ui.set(cfgname, current_name)
end)
local b_create = ui.new_button("Config", "Lua", "Create", function()
    local cname = ui.get(cfgname)
    print(cname)
    if cname ~= nil and cname:gsub("%s+", "") ~= "" then
        ui.set(luabox, -n + selfpos)
        get_activity()
        cfgs[cname] = luat
        --database.write("luacfgs", cfgs)
        client.reload_active_scripts()
    else 
        error("NOCFG")
    end
end)
local b_load = ui.new_button("Config", "Lua", "Load", function()
    local cname = ui.get(cfgname)
    if cname ~= nil and cfgs[cname] ~= nil then
        ui.set(luabox, -n + selfpos)
        print("LOADED: ", inspect(cfgs[cname]))
        --database.write("lua::configname", cname)
        toload = {unpack(cfgs[cname])}
        client.reload_active_scripts()
    else
        error("NOCFG")
    end
end)
local b_save = ui.new_button("Config", "Lua", "Save", function()
    local cname = ui.get(cfgname)
    if cfgs[cname] ~= nil then
        ui.set(luabox, -n + selfpos)
        get_activity()
        cfgs[cname] = luat
        --database.write("luacfgs", cfgs)
        client.reload_active_scripts()
    else
        error("NOCFG")
    end
end)
local b_delete = ui.new_button("Config", "Lua", "Delete", function()
    local cname = ui.get(cfgname)
    cfgs[cname] = nil
    --database.write("luacfgs", cfgs)
    ui.set(luabox, -n + selfpos)
    client.reload_active_scripts()
end)
--every loads button spec overwrite leads to crash
--client.set_event_callback("paint_ui", function()
--    ui.set_visible(loadb, true)
--    ui.set_visible(loadc, true)
--    paint(ui.get(loadb))
--    print(ui.get(luabox))
--end)
--ui.set_callback(loadb, function()
--    print("loaded")
--end)
function globsa()
	print("defered")
    database.write("88821:333333", toload)
    database.write("luacfgs", cfgs)
    database.write("maxluas", maxluas) 
    ui.set(luabox, -n + selfpos)
end
defer(globsa)

--if database.read("lua::configname") ~= nil then
--    local counter = database.read("lua::counter") or 1
--    local cname = database.read("lua::configname")
--    local len = #cfgs[cname]
--    local curr = cfgs[cname][counter]
--    --print(counter)
--    if counter <= len then
--        print("tryid: ", counter)
--        database.write("lua::counter", counter+1)
--        ui.set(luabox, curr)
--        --client.reload_active_scripts()
--        --ui.set(loadc)
--    else
--        print("ended: ", counter)
--        database.write("lua::configname", nil)
--        database.write("lua::counter", nil)
--    end
--end
