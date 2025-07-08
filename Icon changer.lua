local ffi = require("ffi")
local http = require("gamesense/http")
local clip = require("gamesense/clipboard")

local tabs = {"RAGE", "AA", "LEGIT", "VISUALS", "MISC", "SKINS", "PLIST", "CONFIG"}
local types = {"svg", "png", "jpg", "rgba"}

local tabsptr = ffi.cast("intptr_t*", 0x434799AC + 0x54)

local tabsinfo = {}

for i = 0, #tabs do
    local tab = ffi.cast("int*", tabsptr[0])[i]
    tabsinfo[i] = { id = ffi.cast("int*", tab + 0x80), offset = ffi.cast("int*", tab + 0x84), width = ffi.cast("int*", tab + 0x8C), height = ffi.cast("int*", tab + 0x90)}
end

local textures = {
    names = { "Text", "Disabled"},
    info = {{name = "Text", src = nil, id = -1}, {name = "Disabled", src = nil, id = 0}},
}

local function tablevis(tab, bool)
    for _, v in pairs(tab) do
        if type(v) == "table" then
            tablevis(v, bool)
        else
            ui.set_visible(v, bool)
        end
    end
end

local function reset()
    for i = 0, #tabs do
        tabsinfo[i].id[0] = 1
    end
end

local menu = {
    info = {

        tabselector = ui.new_listbox("LUA", "A", "Tab", tabs),
        icon_info = ui.new_button("LUA", "A", "Icon Info", function()end),
        reset = ui.new_button("LUA", "A", "Reset", reset),
    },
    set = {
        textureselector = ui.new_listbox("LUA", "A", "Textures", textures.names),
        set_icon = ui.new_button("LUA", "A", "Set Icon", function()end),
        back = ui.new_button("LUA", "A", "Back", function()end),
    },
    add = {
        typeselector = ui.new_combobox("LUA", "B", "Type", types),
        ui.new_label("LUA", "B", "Name"),
        name = ui.new_textbox("LUA", "B", "Name"),
        down_icon = ui.new_button("LUA", "B", "Download Icon From Clipboard", function()end),
        ui.new_label("LUA", "B", "info:"),
        ui.new_label("LUA", "B", "texture id:"),
        ui.new_label("LUA", "B", "texture offset:"),
        ui.new_label("LUA", "B", "texture width:"),
        ui.new_label("LUA", "B", "texture height:")
    },
}

local function updateinfo()
    local tab = tabsinfo[ui.get(menu.info.tabselector)]
    ui.set(menu.add[2], string.format("%s info:", tabs[ui.get(menu.info.tabselector) + 1]))
    ui.set(menu.add[3], string.format("Texture id: %i", tab.id[0]))
    ui.set(menu.add[4], string.format("Texture offset: %i", tab.offset[0]))
    ui.set(menu.add[5], string.format("Texture width: %i", tab.width[0]))
    ui.set(menu.add[6], string.format("Texture height: %i", tab.height[0]))
end

tablevis(menu.set, false)
ui.set_callback(menu.info.tabselector, updateinfo)
ui.set_callback(menu.info.icon_info, function() tablevis(menu.info, false); tablevis(menu.set, true); end)
ui.set_callback(menu.set.back, function() tablevis(menu.set, false); tablevis(menu.info, true) end)
ui.set_callback(menu.set.set_icon, function()
    local icon = textures.info[ui.get(menu.set.textureselector) + 1]
    local tab = tabsinfo[ui.get(menu.info.tabselector)]
    tab.id[0] = icon.id
end)
ui.set_callback(menu.add.down_icon, function()
    http.get(clip.get(), function(status, response)
        if not status then
            return error(string.format("Cant load %s icon", ui.get(menu.add.name)))
        end
        textures.info[#textures.info + 1] = {name = ui.get(menu.add.name), src = link, id = renderer["load_"..ui.get(menu.add.typeselector)](response.body, 48, 48)}
        textures.names[#textures.names + 1] = ui.get(menu.add.name)
        ui.update(menu.set.textureselector, textures.names)
        ui.set(menu.add.name, "")
    end)
end)

defer(reset)