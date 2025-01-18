--local mainswitch = ui.new_checkbox("AA", "Fake lag", "checkbox")

--import region
local ffi = require("ffi")
local vector = require("vector")
local http = require("gamesense/http")
local inspect = require("gamesense/inspect")
local base64 = require("gamesense/base64")
local websockets = require("gamesense/websockets")
local c_entity = require("gamesense/entity")
local csgo_weapons = require("gamesense/csgo_weapons")
local clipboard = require("gamesense/clipboard")

--local c_effects = require("gamesense/effects")
--import region end
--region говнокода
local utils, colors, cfg, antiaims, logs, indicate, cvardef, hide = {}, {}, {}, {}, {}, {}, {}, {}
utils.menu_col =  function()
    return {ui.get(ui.reference("Misc", "Settings", "Menu color"))}
end
utils.get_screen = function()
    local screen_width, screen_height = client.screen_size()
    return {
        x = screen_width,
        y = screen_height
    }
end
colors.white = {255, 255, 255, 255}
colors.red = {255, 0, 0, 255}
colors.gray = {200, 200, 200, 255}
colors.dark_gray = {92, 92, 92, 255}
colors.skeet_logs = {159, 202, 43, 255}
utils.printr = function(color, ...)
    local logoc = utils.menu_col()
    --[[client.color_log(colors.skeet_logs[1], colors.skeet_logs[2], colors.skeet_logs[3], "[\0")
    client.color_log(logoc[1], logoc[2], logoc[3], "expensive\0")
    client.color_log(colors.skeet_logs[1], colors.skeet_logs[2], colors.skeet_logs[3], "] \0")]]--
    client.color_log(logoc[1], logoc[2], logoc[3], "[expensive] \0")
    client.color_log(colors.dark_gray[1], colors.dark_gray[2], colors.dark_gray[3], "⇋ \0")
    client.color_log(color[1], color[2], color[3], string.format(...))
end
cfg.import = function()
    config.import(clipboard.paste())
    utils.printr(colors.white, "Config Imported From Clipboard!")
end
cfg.export = function()
    local color = get_menuCol()
    utils.printr(colors.white, "Config Exported To Clipboard!")
end
cfg.save = function()
end
cfg.load = function()
end
cfg.names = {"Default"}


local aagui = {
    angles = {
        enabled = ui.reference("AA", "Anti-aimbot angles", "Enabled"),
        pitch = { ui.reference("AA", "Anti-aimbot angles", "Pitch") },
        yaw_base = ui.reference("AA", "Anti-aimbot angles", "Yaw base"),
        yaw = { ui.reference("AA", "Anti-aimbot angles", "Yaw") },
        yaw_jitter = { ui.reference("AA", "Anti-aimbot angles", "Yaw jitter") },
        body_yaw = { ui.reference("AA", "Anti-aimbot angles", "Body yaw") },
        freestanding_body_yaw = ui.reference("AA", "Anti-aimbot angles", "Freestanding body yaw"),
        edge_yaw = ui.reference("AA", "Anti-aimbot angles", "Edge yaw"),
        freestanding = { ui.reference("AA", "Anti-aimbot angles", "Freestanding") },
        roll = ui.reference("AA", "Anti-aimbot angles", "Roll")
    },

    fakelag = {
        enabled = { ui.reference("AA", "Fake lag", "Enabled") },
        amount = ui.reference("AA", "Fake lag", "Amount"),
        variance = ui.reference("AA", "Fake lag", "Variance"),
        limit = ui.reference("AA", "Fake lag", "Limit")
    },

    other = {
        slow_motion = { ui.reference("AA", "Other", "Slow motion") },
        leg_movement = ui.reference("AA", "Other", "Leg movement"),
        on_shot_antiaim = { ui.reference("AA", "Other", "On shot anti-aim") },
        fake_peek = { ui.reference("AA", "Other", "Fake peek") }
    }
}
local ragegui = {
    weapon = {
        weapon_type = ui.reference("Rage", "Weapon type", "Weapon type")
    },

    aimbot = {
        enabled = { ui.reference("Rage", "Aimbot", "Enabled") },
        target_selection = ui.reference("Rage", "Aimbot", "Target selection"),
        minimum_damage = ui.reference("Rage", "Aimbot", "Minimum damage"),
        hitchance = ui.reference('Rage', 'Aimbot', 'Minimum hit chance'),
        auto_scope = ui.reference('Rage', 'Aimbot', 'Automatic Scope'),
        minimum_damage_override = { ui.reference("Rage", "Aimbot", "Minimum damage override") },
        prefer_safe_point = ui.reference("Rage", "Aimbot", "Prefer safe point"),
        force_safe_point = ui.reference("Rage", "Aimbot", "Force safe point"),
        force_body_aim = ui.reference("Rage", "Aimbot", "Force body aim"),
        double_tap = { ui.reference("Rage", "Aimbot", "Double tap") }
    },

    other = {
        quick_peek_assist = { ui.reference("Rage", "Other", "Quick peek assist") },
        duck_peek_assist = ui.reference("Rage", "Other", "Duck peek assist")
    }
}
local visualgui = {
    tperson = {ui.reference("Visuals", "Effects", "Force third person (alive)")}
}
cvardef.default_view = {cvar.viewmodel_fov:get_float(), cvar.viewmodel_offset_x:get_float(), cvar.viewmodel_offset_y :get_float(), cvar.viewmodel_offset_z:get_float()}
cvardef.def_tdist = cvar.cam_idealdist:get_int()
--region @tabs
local tabs = {
    ["Main"] = {
        ui.new_label("AA", "Anti-aimbot angles", "expensive.lua"),
        ui.new_label("AA", "Anti-aimbot angles", "Version: 0.0.1"),
        ui.new_label("AA", "Anti-aimbot angles", "Owner: sakenzo"),
    },
    ["Rage"] = {
        lable = ui.new_label("AA", "Anti-aimbot angles", "Soon")
    },
    ["Anti-Aimbot"] = {
        ui.new_checkbox("AA", "Anti-aimbot angles", "Enable"),
        condition = ui.new_combobox("AA", "Anti-aimbot angles", "Conditions", {"Global", "Standing", "Moving", "Crouch", "Crouch-Moving", "Air", "Air-Crouch", "On-Use"}),
        ["Global"] = {
            ui.new_combobox("AA", "Anti-aimbot angles", "Global ⮞ Pitch", {"Off", "Up", "Down", "Random", "Custom"}),
            pitch = {ui.new_slider("AA", "Anti-aimbot angles", "Global ⮞ Custom Pitch", -89, 89, 0, true, "°", 1, nil)},
            ui.new_combobox("AA", "Anti-aimbot angles", "Global ⮞ Yaw base", {"Local view", "At targets"}),
            ui.new_combobox("AA", "Anti-aimbot angles", "Global ⮞ Yaw jitter", {"Off", "Offset", "Center", "Skitter", "Random"}),
            yaw_jitter = {
                ["Offset"] = ui.new_slider("AA", "Anti-aimbot angles", "Global ⮞ Offset", -180, 180, 0, true, "°", 1, nil),
                ["Center"] = ui.new_slider("AA", "Anti-aimbot angles", "Global ⮞ Center", -180, 180, 0, true, "°", 1, nil),
                ["Skitter"] = ui.new_slider("AA", "Anti-aimbot angles", "Global ⮞ Skitter", -180, 180, 0, true, "°", 1, nil),
                ["Random"] = ui.new_slider("AA", "Anti-aimbot angles", "Global ⮞ Random", -180, 180, 0, true, "°", 1, nil)
            },
            ui.new_combobox("AA", "Anti-aimbot angles", "Global ⮞ Body yaw", {"Off", "Static", "Opposite", "Jitter"}),
            body_yaw = {
                ["Static"] = ui.new_slider("AA", "Anti-aimbot angles", "Global ⮞ Static", -180, 180, 0, true, "°", 1, nil),
                ["Jitter"] = ui.new_slider("AA", "Anti-aimbot angles", "Global ⮞ Jitter", -180, 180, 0, true, "°", 1, nil)
            }
        },
        ["Standing"] = {
            ui.new_checkbox("AA", "Anti-aimbot angles", "Override"),
            ui.new_combobox("AA", "Anti-aimbot angles", "Standing ⮞ Pitch", {"Off", "Up", "Down", "Random", "Custom"}),
            pitch = {ui.new_slider("AA", "Anti-aimbot angles", "Standing ⮞ Custom Pitch", -89, 89, 0, true, "°", 1, nil)},
            ui.new_combobox("AA", "Anti-aimbot angles", "Standing ⮞ Yaw base", {"Local view", "At targets"}),
            ui.new_combobox("AA", "Anti-aimbot angles", "Standing ⮞ Yaw jitter", {"Off", "Offset", "Center", "Skitter", "Random"}),
            yaw_jitter = {
                ["Offset"] = ui.new_slider("AA", "Anti-aimbot angles", "Standing ⮞ Offset", -180, 180, 0, true, "°", 1, nil),
                ["Center"] = ui.new_slider("AA", "Anti-aimbot angles", "Standing ⮞ Center", -180, 180, 0, true, "°", 1, nil),
                ["Skitter"] = ui.new_slider("AA", "Anti-aimbot angles", "Standing ⮞ Skitter", -180, 180, 0, true, "°", 1, nil),
                ["Random"] = ui.new_slider("AA", "Anti-aimbot angles", "Standing ⮞ Random", -180, 180, 0, true, "°", 1, nil)
            },
            ui.new_combobox("AA", "Anti-aimbot angles", "Standing ⮞ Body yaw", {"Off", "Static", "Opposite", "Jitter"}),
            body_yaw = {
                ["Static"] = ui.new_slider("AA", "Anti-aimbot angles", "Standing ⮞ Static", -180, 180, 0, true, "°", 1, nil),
                ["Jitter"] = ui.new_slider("AA", "Anti-aimbot angles", "Standing ⮞ Jitter", -180, 180, 0, true, "°", 1, nil)
            }
        },
        ["Moving"] = {
            ui.new_checkbox("AA", "Anti-aimbot angles", "Override"),
            ui.new_combobox("AA", "Anti-aimbot angles", "Moving ⮞ Pitch", {"Off", "Up", "Down", "Random", "Custom"}),
            pitch = {ui.new_slider("AA", "Anti-aimbot angles", "Moving ⮞ Custom Pitch", -89, 89, 0, true, "°", 1, nil)},
            ui.new_combobox("AA", "Anti-aimbot angles", "Moving ⮞ Yaw base", {"Local view", "At targets"}),
            ui.new_combobox("AA", "Anti-aimbot angles", "Moving ⮞ Yaw jitter", {"Off", "Offset", "Center", "Skitter", "Random"}),
            yaw_jitter = {
                ["Offset"] = ui.new_slider("AA", "Anti-aimbot angles", "Moving ⮞ Offset", -180, 180, 0, true, "°", 1, nil),
                ["Center"] = ui.new_slider("AA", "Anti-aimbot angles", "Moving ⮞ Center", -180, 180, 0, true, "°", 1, nil),
                ["Skitter"] = ui.new_slider("AA", "Anti-aimbot angles", "Moving ⮞ Skitter", -180, 180, 0, true, "°", 1, nil),
                ["Random"] = ui.new_slider("AA", "Anti-aimbot angles", "Moving ⮞ Random", -180, 180, 0, true, "°", 1, nil)
            },
            ui.new_combobox("AA", "Anti-aimbot angles", "Moving ⮞ Body yaw", {"Off", "Static", "Opposite", "Jitter"}),
            body_yaw = {
                ["Static"] = ui.new_slider("AA", "Anti-aimbot angles", "Moving ⮞ Static", -180, 180, 0, true, "°", 1, nil),
                ["Jitter"] = ui.new_slider("AA", "Anti-aimbot angles", "Moving ⮞ Jitter", -180, 180, 0, true, "°", 1, nil)
            }
        },
        ["Crouch"] = {
            ui.new_checkbox("AA", "Anti-aimbot angles", "Override"),
            ui.new_combobox("AA", "Anti-aimbot angles", "Crouch ⮞ Pitch", {"Off", "Up", "Down", "Random", "Custom"}),
            pitch = {ui.new_slider("AA", "Anti-aimbot angles", "Crouch ⮞ Custom Pitch", -89, 89, 0, true, "°", 1, nil)},
            ui.new_combobox("AA", "Anti-aimbot angles", "Crouch ⮞ Yaw base", {"Local view", "At targets"}),
            ui.new_combobox("AA", "Anti-aimbot angles", "Crouch ⮞ Yaw jitter", {"Off", "Offset", "Center", "Skitter", "Random"}),
            yaw_jitter = {
                ["Offset"] = ui.new_slider("AA", "Anti-aimbot angles", "Crouch ⮞ Offset", -180, 180, 0, true, "°", 1, nil),
                ["Center"] = ui.new_slider("AA", "Anti-aimbot angles", "Crouch ⮞ Center", -180, 180, 0, true, "°", 1, nil),
                ["Skitter"] = ui.new_slider("AA", "Anti-aimbot angles", "Crouch ⮞ Skitter", -180, 180, 0, true, "°", 1, nil),
                ["Random"] = ui.new_slider("AA", "Anti-aimbot angles", "Crouch ⮞ Random", -180, 180, 0, true, "°", 1, nil)
            },
            ui.new_combobox("AA", "Anti-aimbot angles", "Crouch ⮞ Body yaw", {"Off", "Static", "Opposite", "Jitter"}),
            body_yaw = {
                ["Static"] = ui.new_slider("AA", "Anti-aimbot angles", "Crouch ⮞ Static", -180, 180, 0, true, "°", 1, nil),
                ["Jitter"] = ui.new_slider("AA", "Anti-aimbot angles", "Crouch ⮞ Jitter", -180, 180, 0, true, "°", 1, nil)
            }
        },
        ["Crouch-Moving"] = {
            ui.new_checkbox("AA", "Anti-aimbot angles", "Override"),
            ui.new_combobox("AA", "Anti-aimbot angles", "Crouch-Moving ⮞ Pitch", {"Off", "Up", "Down", "Random", "Custom"}),
            pitch = {ui.new_slider("AA", "Anti-aimbot angles", "Crouch-Moving ⮞ Custom Pitch", -89, 89, 0, true, "°", 1, nil)},
            ui.new_combobox("AA", "Anti-aimbot angles", "Crouch-Moving ⮞ Yaw base", {"Local view", "At targets"}),
            ui.new_combobox("AA", "Anti-aimbot angles", "Crouch-Moving ⮞ Yaw jitter", {"Off", "Offset", "Center", "Skitter", "Random"}),
            yaw_jitter = {
                ["Offset"] = ui.new_slider("AA", "Anti-aimbot angles", "Crouch-Moving ⮞ Offset", -180, 180, 0, true, "°", 1, nil),
                ["Center"] = ui.new_slider("AA", "Anti-aimbot angles", "Crouch-Moving ⮞ Center", -180, 180, 0, true, "°", 1, nil),
                ["Skitter"] = ui.new_slider("AA", "Anti-aimbot angles", "Crouch-Moving ⮞ Skitter", -180, 180, 0, true, "°", 1, nil),
                ["Random"] = ui.new_slider("AA", "Anti-aimbot angles", "Crouch-Moving ⮞ Random", -180, 180, 0, true, "°", 1, nil)
            },
            ui.new_combobox("AA", "Anti-aimbot angles", "Crouch-Moving ⮞ Body yaw", {"Off", "Static", "Opposite", "Jitter"}),
            body_yaw = {
                ["Static"] = ui.new_slider("AA", "Anti-aimbot angles", "Crouch-Moving ⮞ Static", -180, 180, 0, true, "°", 1, nil),
                ["Jitter"] = ui.new_slider("AA", "Anti-aimbot angles", "Crouch-Moving ⮞ Jitter", -180, 180, 0, true, "°", 1, nil)
            }
        },
        ["Air"] = {
            ui.new_checkbox("AA", "Anti-aimbot angles", "Override"),
            ui.new_combobox("AA", "Anti-aimbot angles", "Air ⮞ Pitch", {"Off", "Up", "Down", "Random", "Custom"}),
            pitch = {ui.new_slider("AA", "Anti-aimbot angles", "Air ⮞ Custom Pitch", -89, 89, 0, true, "°", 1, nil)},
            ui.new_combobox("AA", "Anti-aimbot angles", "Air ⮞ Yaw base", {"Local view", "At targets"}),
            ui.new_combobox("AA", "Anti-aimbot angles", "Air ⮞ Yaw jitter", {"Off", "Offset", "Center", "Skitter", "Random"}),
            yaw_jitter = {
                ["Offset"] = ui.new_slider("AA", "Anti-aimbot angles", "Air ⮞ Offset", -180, 180, 0, true, "°", 1, nil),
                ["Center"] = ui.new_slider("AA", "Anti-aimbot angles", "Air ⮞ Center", -180, 180, 0, true, "°", 1, nil),
                ["Skitter"] = ui.new_slider("AA", "Anti-aimbot angles", "Air ⮞ Skitter", -180, 180, 0, true, "°", 1, nil),
                ["Random"] = ui.new_slider("AA", "Anti-aimbot angles", "Air ⮞ Random", -180, 180, 0, true, "°", 1, nil)
            },
            ui.new_combobox("AA", "Anti-aimbot angles", "Air ⮞ Body yaw", {"Off", "Static", "Opposite", "Jitter"}),
            body_yaw = {
                ["Static"] = ui.new_slider("AA", "Anti-aimbot angles", "Air ⮞ Static", -180, 180, 0, true, "°", 1, nil),
                ["Jitter"] = ui.new_slider("AA", "Anti-aimbot angles", "Air ⮞ Jitter", -180, 180, 0, true, "°", 1, nil)
            }
        },
        ["Air-Crouch"] = {
            ui.new_checkbox("AA", "Anti-aimbot angles", "Override"),
            ui.new_combobox("AA", "Anti-aimbot angles", "Air-Crouch ⮞ Pitch", {"Off", "Up", "Down", "Random", "Custom"}),
            pitch = {ui.new_slider("AA", "Anti-aimbot angles", "Air-Crouch ⮞ Custom Pitch", -89, 89, 0, true, "°", 1, nil)},
            ui.new_combobox("AA", "Anti-aimbot angles", "Air-Crouch ⮞ Yaw base", {"Local view", "At targets"}),
            ui.new_combobox("AA", "Anti-aimbot angles", "Air-Crouch ⮞ Yaw jitter", {"Off", "Offset", "Center", "Skitter", "Random"}),
            yaw_jitter = {
                ["Offset"] = ui.new_slider("AA", "Anti-aimbot angles", "Air-Crouch ⮞ Offset", -180, 180, 0, true, "°", 1, nil),
                ["Center"] = ui.new_slider("AA", "Anti-aimbot angles", "Air-Crouch ⮞ Center", -180, 180, 0, true, "°", 1, nil),
                ["Skitter"] = ui.new_slider("AA", "Anti-aimbot angles", "Air-Crouch ⮞ Skitter", -180, 180, 0, true, "°", 1, nil),
                ["Random"] = ui.new_slider("AA", "Anti-aimbot angles", "Air-Crouch ⮞ Random", -180, 180, 0, true, "°", 1, nil)
            },
            ui.new_combobox("AA", "Anti-aimbot angles", "Air-Crouch ⮞ Body yaw", {"Off", "Static", "Opposite", "Jitter"}),
            body_yaw = {
                ["Static"] = ui.new_slider("AA", "Anti-aimbot angles", "Air-Crouch ⮞ Static", -180, 180, 0, true, "°", 1, nil),
                ["Jitter"] = ui.new_slider("AA", "Anti-aimbot angles", "Air-Crouch ⮞ Jitter", -180, 180, 0, true, "°", 1, nil)
            }
        },
        ["On-Use"] = {
            ui.new_checkbox("AA", "Anti-aimbot angles", "Override"),
            ui.new_combobox("AA", "Anti-aimbot angles", "On-Use ⮞ Pitch", {"Off", "Up", "Down", "Random", "Custom"}),
            pitch = {ui.new_slider("AA", "Anti-aimbot angles", "On-Use ⮞ Custom Pitch", -89, 89, 0, true, "°", 1, nil)},
            ui.new_combobox("AA", "Anti-aimbot angles", "On-Use ⮞ Yaw base", {"Local view", "At targets"}),
            ui.new_combobox("AA", "Anti-aimbot angles", "On-Use ⮞ Yaw jitter", {"Off", "Offset", "Center", "Skitter", "Random"}),
            yaw_jitter = {
                ["Offset"] = ui.new_slider("AA", "Anti-aimbot angles", "On-Use ⮞ Offset", -180, 180, 0, true, "°", 1, nil),
                ["Center"] = ui.new_slider("AA", "Anti-aimbot angles", "On-Use ⮞ Center", -180, 180, 0, true, "°", 1, nil),
                ["Skitter"] = ui.new_slider("AA", "Anti-aimbot angles", "On-Use ⮞ Skitter", -180, 180, 0, true, "°", 1, nil),
                ["Random"] = ui.new_slider("AA", "Anti-aimbot angles", "On-Use ⮞ Random", -180, 180, 0, true, "°", 1, nil)
            },
            ui.new_combobox("AA", "Anti-aimbot angles", "On-Use ⮞ Body yaw", {"Off", "Static", "Opposite", "Jitter"}),
            body_yaw = {
                ["Static"] = ui.new_slider("AA", "Anti-aimbot angles", "On-Use ⮞ Static", -180, 180, 0, true, "°", 1, nil),
                ["Jitter"] = ui.new_slider("AA", "Anti-aimbot angles", "On-Use ⮞ Jitter", -180, 180, 0, true, "°", 1, nil)
            }
        },
        ["Manuals"] = {
            ui.new_checkbox("AA", "Anti-aimbot angles", "Manuals"),
            ui.new_label("AA", "Anti-aimbot angles", "Left"),
            ui.new_hotkey("AA", "Anti-aimbot angles", "Left", true, 0x00),
            ui.new_label("AA", "Anti-aimbot angles", "Right"),
            ui.new_hotkey("AA", "Anti-aimbot angles", "Right", true, 0x00),
            ui.new_label("AA", "Anti-aimbot angles", "Reset"),
            ui.new_hotkey("AA", "Anti-aimbot angles", "Reset", true, 0x00)
        }
    },
    ["Visuals"] = {
        indicators = {
            ui.new_checkbox("AA", "Anti-aimbot angles", "Indicators")
        },
        nimbus = {
            ui.new_checkbox("AA", "Anti-aimbot angles", "Nimbus"),
            ui.new_color_picker("AA", "Anti-aimbot angles", "Nimbus Color", 255, 255, 255, 255)
        }
    },
    ["Misc"] = {
        tperson = {
            ui.new_checkbox("AA", "Anti-aimbot angles", 'Thirdperson Distance'),
            ui.new_slider("AA", "Anti-aimbot angles", "Distance", 10, 100, cvardef.def_tdist, true, nil, 1, nil)
        },
        aspectratio = {
            ui.new_checkbox("AA", "Anti-aimbot angles", 'Aspect Ratio'),
            ui.new_slider("AA", "Anti-aimbot angles", "Ratio", 0, 200, 100, true, nil, 0.01, nil)
        },
        viewmodel = {
            ui.new_checkbox("AA", "Anti-aimbot angles", 'Viewmodel Changer'),
            ui.new_slider("AA", "Anti-aimbot angles", "Fov", -900, 900, cvardef.default_view[1], true, nil, 0.1, nil),
            ui.new_slider("AA", "Anti-aimbot angles", "X", -900, 900, cvardef.default_view[2], true, nil, 0.1, nil),
            ui.new_slider("AA", "Anti-aimbot angles", "Y", -900, 900, cvardef.default_view[3], true, nil, 0.1, nil),
            ui.new_slider("AA", "Anti-aimbot angles", "Z", -900, 900, cvardef.default_view[4], true, nil, 0.1, nil)
        },
        ducarigym = {
            ui.new_checkbox("AA", "Anti-aimbot angles", 'Ducari in gym'),
            ui.new_slider("AA", "Anti-aimbot angles", "Scale", 1, 10, 10, true, nil, 0.1, nil),
        },
        animbreak = {
            ui.new_checkbox("AA", "Anti-aimbot angles", 'Animation Breaker'),
            ui.new_combobox("AA", "Anti-aimbot angles", "Air", {"Disabled", "Ground Animlayer", "Jitter", "Static Legs", "Allah", "Crab", "T-Pose"}),
            ui.new_combobox("AA", "Anti-aimbot angles", "Ground", {"Disabled", "Static", "Jitter", "Allah", "Crab", "Forwards", "Backwards", "T-Pose"}),
            ui.new_combobox("AA", "Anti-aimbot angles", "Move Lean", {"Disabled", "Affected"}),
            ui.new_multiselect("AA", "Anti-aimbot angles", "Aditional Breaker", {"Air", "Ground"}),
            ui.new_combobox("AA", "Anti-aimbot angles", "Aditional Breaker Conditions", {"Flashed", "Piano"}),
        },
        logs = {
            ui.new_checkbox("AA", "Anti-aimbot angles", 'Aimbot Logs'),
            ui.new_multiselect("AA", "Anti-aimbot angles", "Location", {"Console", "Screen"}),
            ui.new_multiselect("AA", "Anti-aimbot angles", "Events", {"On Hit", "On Miss"}),
            ui.new_label("AA", "Anti-aimbot angles", "On Hit Color"),
            ui.new_color_picker("AA", "Anti-aimbot angles", "Hit Logs Color", colors.skeet_logs[1], colors.skeet_logs[2], colors.skeet_logs[3]),
            ui.new_label("AA", "Anti-aimbot angles", "On Miss Color"),
            ui.new_color_picker("AA", "Anti-aimbot angles", "Miss Logs Color", 255, 180, 0)
        }
    },
    ["Configs"] = {
        configbox = ui.new_listbox("AA", "Anti-aimbot angles", "Configs", cfg.names),
        textbox = ui.new_textbox("AA", "Anti-aimbot angles", "Config Name"),
        loadcfg = ui.new_button("AA", "Anti-aimbot angles", "Load Config", cfg.load),
        savecfg = ui.new_button("AA", "Anti-aimbot angles", "Save Config", cfg.save),
        importcfg = ui.new_button("AA", "Anti-aimbot angles", "Import Config", cfg.import),
        exportcfg = ui.new_button("AA", "Anti-aimbot angles", "Export Config", cfg.export)
    }
}
--region @tabs end
ui.set_callback(tabs["Configs"].configbox, function()
    local configname = cfg.names[ui.get(tabs["Configs"].configbox) + 1]
    if configname == nil then return end
    ui.set(tabs["Configs"].textbox, configname)
end)
local function discordclbck()
    clipboard.copy("https://discord.gg/jw5WmajZPQ")
    utils.printr(colors.white, "Discord Copied To Clipboard!")
end
local switch = ui.new_combobox("AA", "Fake lag", "Tabs", {"Main", "Rage", "Anti-Aimbot", "Visuals", "Misc", "Configs"})
ui.new_button("AA", "Fake lag", "Discord", discordclbck)
utils.multi_parse = function(multiselect, val)
    for _, v in pairs(ui.get(multiselect)) do
        if v == val then
            return true
        end
    end
    return false
end
utils.combo_parse = function(combo, ...)
    args = {...}
    for i=1, #args, 1 do
        if args[i] == combo then
            return true
        end
    end
    return false
end

utils.visibleparse = function(tables, bool)
    if type(tables) == "number" then
        if bool == false then
            table.insert(hide, tables)
        end
        ui.set_visible(tables, bool)
    else 
        for _, t in pairs(tables) do
            utils.visibleparse(t, bool)
        end
    end
end
utils.visible_misc = function()
    for k, v in pairs(tabs["Misc"]) do
        for _, val in pairs(v) do
            if val == v[1] then
                ui.set_visible(v[1], true)
            else 
                if val == tabs["Misc"].animbreak[6] then
                    ui.set_visible(val, ui.get(tabs["Misc"].animbreak[5])[1] ~= nil)
                else
                    ui.set_visible(val, ui.get(v[1]))
                end
            end
        end
    end
end
utils.set_visibleA = function(tables, val)
    for k, v in pairs(tables) do
        if k == val then
            ui.set_visible(v, true)
        else
            ui.set_visible(v, false)
        end
    end
end
utils.checkbox_visible = function(tab)
    for k, v in pairs(tab) do
        for _, val in pairs(v) do
            if val == v[1] then
                ui.set_visible(v[1], true)
            else 
                ui.set_visible(val, ui.get(v[1]))
            end
        end
    end
end
utils.visible_aa = function()
    local tab = tabs["Anti-Aimbot"]
    local enabled =  ui.get(tab[1])
    local cond = ui.get(tab.condition)
    for k, v in pairs(tab) do
        if v ~= tab[1] then
            utils.visibleparse(tab.condition, enabled)
            utils.visibleparse(tab["Manuals"][1], enabled)
            if k == cond then
                for key, value in pairs(v) do
                    if type(value) == "number" then
                        ui.set_visible(value, enabled)
                    elseif value == tab[cond].pitch then
                        local ptype = ui.get(cond == "Global" and tab[cond][1] or tab[cond][2])
                        ui.set_visible(value[1], utils.combo_parse(ptype, "Custom"))
                    elseif value == tab[cond].yaw_jitter then
                        local yaw_jtype = ui.get(cond == "Global" and tab[cond][3] or tab[cond][4])
                        if yaw_jtype ~= "Off" then
                            utils.set_visibleA(value, yaw_jtype)
                        else
                            utils.visibleparse(value, false)
                        end
                    elseif value == tab[cond].body_yaw then
                        local body_ytype = ui.get(cond == "Global" and tab[cond][4] or tab[cond][5])
                        if not utils.combo_parse(body_ytype, "Off", "Opposite") then
                            utils.set_visibleA(value, body_ytype)
                        else
                            utils.visibleparse(value, false)
                        end
                    end
                end
            elseif k == "Manuals" then
                for key, val in pairs(v) do
                    if val ~= tab["Manuals"][1] then
                        ui.set_visible(val, ui.get(tab["Manuals"][1]))
                    end
                end
            else 
                utils.visibleparse(v, false)
            end
        else
            ui.set_visible(v, true)
        end
    end

end
utils.visible_tabs = function(tables)
    tables = tables ~= nil and tables or tabs
    if type(tables) == "table" then
        for k, v in pairs(tables) do
            if ui.get(switch) == k then
                if k == "Misc" then
                    utils.visible_misc()
                elseif k == "Visuals" then
                    utils.checkbox_visible(v)
                elseif k == "Anti-Aimbot" then
                    utils.visible_aa()
                else
                    utils.visibleparse(v, true)
                end
            else
                utils.visibleparse(v, false)
            end
        end
    end
end
local function menu_visible()
    utils.visible_tabs()
    utils.visibleparse(aagui.angles, false)
    utils.visibleparse(aagui.fakelag, false)
end


local acts = {
    ["AIM_MATRIX"] = {
        ["RESET"] = 0,
        ["TPOSE"] = 11,
        ["SELFKILL"] = 59,
        ["PIANO"] = 61,
        ["KNIFE_AFTER_TAB"] = 168,
        ["BACKHAND"] = 200,
        ["DEFUSING"] = 220,
        ["FLASHBANG_LIGHT"] = 224,
        ["FLASHBANG_MASSIVE"] = 225
    },
    ["WEAPON_ACTION"] = {
        ["ENDGAME_POSE"] = 10,
        ["AEROBIC"] = 11,
        ["DEAGLE_SWITCH"] = 35,
        ["AK47_SWITCH"] = 37,
        ["SCOUT_SWITCH"] = 43,
        ["AK47_SWITCH"] = 52,
        ["SPIN"] = 60,
        ["FAST_RECHARGE"] = 163,
        ["REVERSED_BACKSTAB"] = 190,
        ["NADE_RANGED"] = 204,
        ["FLASHBANG_LIGHT"] = 224,
        ["FLASHBANG_MASSIVE"] = 225,
        ["SURRENDER"] = 232,
        ["KNEES"] = 262
    },
    ["MOVEMENT_MOVE"] = {
        ["ENDGAME_POSE"] = 10,
        ["CHAOS"] = 11,
        ["STAIRS"] = 13,
        ["SQUATS"] = 22,
        ["DEAGLE_SWITCH"] = 35,
        ["AK47_SWITCH"] = 37,
        ["SCOUT_SWITCH"] = 43,
        ["R8_SWITCH"] = 60,
        ["SILENCER_ON_USP"] = 100,
        ["RECHARGE_AUG"] = 114,
        ["SILENCER_OFF_M4"] = 115,
        ["KNIFE_TAB"] = 187,
        ["KNIFE_BACKSTAB"] = 190,
        ["DEFUSING"] = 220,
        ["C4_PLANT"] = 223,
        ["FLASHBANG_LIGHT"] = 224,
        ["FLASHBANG_MASSIVE"] = 225,
        ["SURRENDER"] = 232,
        ["KNEES"] = 262
    }
}
local animfucks = {
    ["Crab"] = {0.8, 7, "Never slide"},
    ["Static Legs"] = {1, 6},
    ["Allah"] = {0, 7, "Never slide"},
    ["Forwards"] = {0.5, 0, "Always slide"},
    ["Backwards"] = {1, 0, "Always slide"},
    ["Static"] = {6, 0, acts["AIM_MATRIX"]["RESET"]},
    ["T-Pose"] = {12, acts["AIM_MATRIX"]["TPOSE"]},
    ["Flashed"] = {0, acts["AIM_MATRIX"]["FLASHBANG_LIGHT"]},
    ["Piano"] = {0, acts["AIM_MATRIX"]["PIANO"]}
}
local function animfuck(cmd)
    local lplayer = entity.get_local_player()
    if lplayer == nil then return end
    if not entity.is_alive(lplayer) then return end
    local self_index = c_entity.new(lplayer)
    local self_anim_state = self_index:get_anim_state()
    if not self_anim_state then return end
    local self_anim_overlay = self_index:get_anim_overlay(6)
    local self_anim_overlay_lean = self_index:get_anim_overlay(12)
    local air_sel = ui.get(tabs["Misc"].animbreak[2])
    local ground_sel = ui.get(tabs["Misc"].animbreak[3])
    local seq_cond = ui.get(tabs["Misc"].animbreak[6])
    local move_sel = ui.get(tabs["Misc"].animbreak[4])
    local add_fuck = self_index:get_anim_overlay(animfucks[seq_cond][1])
    if ui.get(tabs["Misc"].animbreak[1]) then
        if utils.combo_parse(move_sel, "Affected") then
            self_anim_overlay_lean.weight = 1
        else
            self_anim_overlay_lean.weight = 0
        end
        if self_anim_state.on_ground then
            if utils.multi_parse(tabs["Misc"].animbreak[5], "Ground") then
                add_fuck.weight = 1
                add_fuck.sequence = animfucks[seq_cond][2]
            end
            if not utils.combo_parse(ground_sel, "Disabled") then
                if utils.combo_parse(ground_sel, "Static", "T-Pose") then
                    ui.set(aagui.other.leg_movement, "Off")
                    local groundfuck = self_index:get_anim_overlay(animfucks[ground_sel][1])
                    groundfuck.weight = 1
                    groundfuck.sequence = animfucks[ground_sel][2]
                elseif utils.combo_parse(ground_sel, "Jitter") then
                    entity.set_prop(lplayer, 'm_flPoseParameter', 1, globals.tickcount() % 4 > 1 and 0.5 or 1)
                else 
                    ui.set(aagui.other.leg_movement, animfucks[ground_sel][3])
                    entity.set_prop(lplayer, "m_flPoseParameter", animfucks[ground_sel][1], animfucks[ground_sel][2])
                end
            end
        else
            if utils.multi_parse(tabs["Misc"].animbreak[5], "Air") then
                add_fuck.weight = 1
                add_fuck.sequence = animfucks[seq_cond][2]
            end
            if not utils.combo_parse(air_sel, "Disabled") then
                if not utils.combo_parse(air_sel, "Static Legs", "Jitter") then
                    self_anim_overlay.weight = 1
                end
                if utils.combo_parse(air_sel, "T-Pose") then
                    ui.set(aagui.other.leg_movement, "Off")
                    local air_fuck = self_index:get_anim_overlay(animfucks[air_sel][1])
                    air_fuck.weight = 1
                    air_fuck.sequence = animfucks[air_sel][2]
                elseif not utils.combo_parse(air_sel, "Ground Animlayer", "Jitter") then
                    entity.set_prop(lplayer, "m_flPoseParameter", animfucks[air_sel][1], animfucks[air_sel][2])
                elseif utils.combo_parse(air_sel, "Jitter") then
                    entity.set_prop(lplayer, "m_flPoseParameter", 1, globals.tickcount() % 4 > 1 and 0 or 6)
                end
            end
        end
    end
end
local function jitterfuck(cmd)
    local lplayer = entity.get_local_player()
    if lplayer == nil then return end
    if ui.get(tabs["Misc"].animbreak[1]) and utils.combo_parse(ui.get(tabs["Misc"].animbreak[3]), "Jitter") then
        ui.set(aagui.other.leg_movement, cmd.command_number % 3 == 0 and 'Off' or 'Always slide')
    end
end
local function aspect_change(reset)
    local ratio_slider = ui.get(tabs["Misc"].aspectratio[2])*0.01
    ratio_slider = 2 - ratio_slider
    local screen = utils.get_screen()
    local aspect_value = (screen.x*ratio_slider)/screen.y
    if ratio_slider == 1 then
		aspect_value = 0
	end
    if not ui.get(tabs["Misc"].aspectratio[1]) or reset then aspect_value = 0 end
    client.set_cvar("r_aspectratio", tonumber(aspect_value))
end
local function tpdist(reset)
    if not ui.get(tabs["Misc"].tperson[1]) or reset then
        cvar.c_mindistance:set_int(cvardef.def_tdist)
        cvar.c_maxdistance:set_int(cvardef.def_tdist)
    else
        ui.set_callback(tabs["Misc"].tperson[2], function()
            cvar.c_mindistance:set_int(ui.get(tabs["Misc"].tperson[2]))
            cvar.c_maxdistance:set_int(ui.get(tabs["Misc"].tperson[2]))
        end)
    end
end

local function viewmod(reset)
    local cvar_fov = cvar.viewmodel_fov
    local cvar_offset_x = cvar.viewmodel_offset_x
    local cvar_offset_y = cvar.viewmodel_offset_y 
    local cvar_offset_z = cvar.viewmodel_offset_z
    local fov, x, y, z
    if not ui.get(tabs["Misc"].viewmodel[1]) then
        fov = cvardef.default_view[1]
        x = cvardef.default_view[2]
        y = cvardef.default_view[3]
        z = cvardef.default_view[4]
        cvar_fov:set_raw_float(fov)
        cvar_offset_x:set_raw_float(x)
        cvar_offset_y:set_raw_float(y)
        cvar_offset_z:set_raw_float(z)
    else
        fov = ui.get(tabs["Misc"].viewmodel[2])
        x = ui.get(tabs["Misc"].viewmodel[3])
        y = ui.get(tabs["Misc"].viewmodel[4])
        z = ui.get(tabs["Misc"].viewmodel[5])
        ui.set_callback(tabs["Misc"].viewmodel[2], function() cvar_fov:set_raw_float(fov) end)
        ui.set_callback(tabs["Misc"].viewmodel[3], function() cvar_offset_x:set_raw_float(x) end)
        ui.set_callback(tabs["Misc"].viewmodel[4], function() cvar_offset_y:set_raw_float(y) end)
        ui.set_callback(tabs["Misc"].viewmodel[5], function() cvar_offset_z:set_raw_float(z) end)
    end
end
local function ScaleModel(reset)
    local lplayer = entity.get_local_player()
    if lplayer == nil then return end
    local scale = ui.get(tabs["Misc"].ducarigym[2]) * 0.1
    if reset then scale = 1 end
    if ui.get(tabs["Misc"].ducarigym[1]) then
        entity.set_prop(lplayer, "m_flModelScale", scale, 0)
    else 
        entity.set_prop(lplayer, "m_flModelScale", 1, 0)
    end
end

--region @logger
logs.hitboxes = {
    [0] = "generic",
    [1] = "head",
    [2] = "chest",
    [3] = "stomach",
    [4] = "left arm",
    [5] = "right arm",
    [6] = "left leg",
    [7] = "right leg",
    [8] = "neck",
    [9] = "?",
    [10] = "gear"
}

logs.printl = function(...)
    args = {...}
    for i=1, #args, 1 do
        arg = args[i]
        seg_col, segment = unpack(arg)
        if #args > i then
            segment = segment..'\0'
        end
        client.color_log(seg_col[1], seg_col[2], seg_col[3], segment)
    end
end
logs.get_safety = function(aim_data, target)
	local has_been_boosted = aim_data.boosted
	local plist_safety = plist.get(target, 'Override safe point')
	local ui_safety = { ui.get(ragegui.aimbot.prefer_safe_point), ui.get(ragegui.aimbot.force_safe_point) or plist_safety == 'On' }

	if not has_been_boosted then
		return -1
	end

	if plist_safety == 'Off' or not (ui_safety[1] or ui_safety[2]) then
		return 0
	end

	return ui_safety[2] and 2 or (ui_safety[1] and 1 or 0)
end

logs.bullet_impacts = {}
logs.bullet_impact = function(e)
	local tick = globals.tickcount()
	local me = entity.get_local_player()
	local user = client.userid_to_entindex(e.userid)
	
	if user ~= me then
		return
	end

	if #logs.bullet_impacts > 150 then
		logs.bullet_impacts = { }
	end

	logs.bullet_impacts[#logs.bullet_impacts+1] = {
		tick = tick,
		eye = vector(client.eye_position()),
		shot = vector(e.x, e.y, e.z)
	}
end
logs.get_inaccuracy_tick = function(pre_data, tick)
	local spread_angle = -1
	for k, impact in pairs(logs.bullet_impacts) do
		if impact.tick == tick then
			local aim, shot = 
				(pre_data.eye-pre_data.shot_pos):angles(),
				(pre_data.eye-impact.shot):angles()

				spread_angle = vector(aim-shot):length2d()
			break
		end
	end

	return spread_angle
end
logs.gen_flags = function(flags)
    res = {}
    for i=1, #flags, 1 do
        if flags[i] ~= "" then
            table.insert(res, flags[i])
        end
    end
    return res
end

logs.on_fire = function(e)
    if not ui.get(tabs["Misc"].logs[1]) then return end
    local p_ent = e.target
	local me = entity.get_local_player()

	logs[e.id] = {
		original = e,
		dropped_packets = { },

		handle_time = globals.realtime(),
		self_choke = globals.chokedcommands(),

		flags = {
            e.teleported and "Teleported" or "",
            e.interpolated and "Interpolated" or "",
            e.extrapolated and "Extrapolated" or "",
            e.boosted and "Boosted" or "",
            e.high_priority and "High Priority" or ""
		},

		feet_yaw = entity.get_prop(p_ent, 'm_flPoseParameter', 11)*120-60,
		correction = plist.get(p_ent, 'Correction active'),

		safety = logs.get_safety(e, p_ent),
		shot_pos = vector(e.x, e.y, e.z),
		eye = vector(client.eye_position()),
		view = vector(client.camera_angles()),

		velocity_modifier = entity.get_prop(me, 'm_flVelocityModifier'),
		total_hits = entity.get_prop(me, 'm_totalHitsOnServer'),

		history = globals.tickcount() - e.tick
	}
end
logs.on_hit = function(e)
    if logs[e.id] == nil then return end
    if not ui.get(tabs["Misc"].logs[1]) then return end
    if not utils.multi_parse(tabs["Misc"].logs[2], "Console") or not utils.multi_parse(tabs["Misc"].logs[3], "On Hit") then return end
    local info = 
    {
        col = {ui.get(tabs["Misc"].logs[5])},
        type = math.max(0, entity.get_prop(e.target, 'm_iHealth')) > 0,
        name = entity.get_player_name(e.target),
        hitgroup = logs.hitboxes[e.hitgroup] or '?',
        flags = string.format('%s', table.concat(logs.gen_flags(logs[e.id].flags), " | ")),
        aimed_hitgroup = logs.hitboxes[logs[e.id].original.hitgroup] or '?',
        aimed_hitchance = string.format('%d%%', math.floor(logs[e.id].original.hit_chance + 0.5)),
        hp = math.max(0, entity.get_prop(e.target, 'm_iHealth')),
        spread_angle = string.format('%.2f°', logs.get_inaccuracy_tick(logs[e.id], globals.tickcount())),
        correction = string.format('%d:%d°', logs[e.id].correction and 1 or 0, (logs[e.id].feet_yaw < 10 and logs[e.id].feet_yaw > -10) and 0 or logs[e.id].feet_yaw)
    }
    utils.printr(colors.white, '\0')
    logs.printl(
        {info.col, info.type and "Hit " or "Killed "},
        {colors.gray, info.name},
        {colors.gray, " in "},
        {info.col, info.hitgroup},
        {colors.gray, info.type and info.hitgroup ~= info.aimed_hitgroup and " (" or ""},
        {info.col, info.type and (info.hitgroup ~= info.aimed_hitgroup and info.aimed_hitgroup) or ""},
        {colors.gray, info.type and info.hitgroup ~= info.aimed_hitgroup and ')' or ''},
        {colors.gray, info.type and " for " or ""},
        {info.col, info.type and e.damage or "" },
        {colors.gray, info.type and e.damage ~= logs[e.id].original.damage and " (" or ""},
        {info.col, info.type and (e.damage ~= logs[e.id].original.damage and logs[e.id].original.damage) or ""},
        {colors.gray, info.type and e.damage ~= logs[e.id].original.damage and ")" or ""},
        {colors.gray, info.type and " damage" or ""},
        {colors.gray, info.type and " (" or "" },
        {info.col, info.type and info.hp or ""}, 
        {colors.gray, info.type and " hp remaning)" or ""},
        {colors.gray, " ["},
        {info.col, info.spread_angle}, 
        {colors.gray, " | "}, 
        {info.col, info.correction}, 
        {colors.gray, " ] "},
        {colors.gray, " (hc: "},
        {info.col, info.aimed_hitchance},
        {colors.gray, " | safety: "},
        {info.col, logs[e.id].safety},
        {colors.gray, " | backtrack: " }, 
        {info.col, logs[e.id].history.."t"}, 
        {colors.gray, " | flags: "}, 
        {info.col, info.flags},
        {colors.gray, ")"}
    )
end
logs.on_miss = function(e)
    if not ui.get(tabs["Misc"].logs[1]) then return end
    if not utils.multi_parse(tabs["Misc"].logs[2], "Console") or not utils.multi_parse(tabs["Misc"].logs[3], "On Miss") then return end
    local lplayer = entity.get_local_player()
    local info = 
    {
        col = {ui.get(tabs["Misc"].logs[7])},
        name = entity.get_player_name(e.target),
        hitgroup = logs.hitboxes[e.hitgroup] or '?',
        flags = string.format('%s', table.concat(logs.gen_flags(logs[e.id].flags), " | ")),
        aimed_hitgroup = logs.hitboxes[logs[e.id].original.hitgroup] or '?',
        aimed_hitchance = string.format('%d%%', math.floor(logs[e.id].original.hit_chance + 0.5)),
        hp = math.max(0, entity.get_prop(e.target, 'm_iHealth')),
        reason = e.reason,
        spread_angle = string.format('%.2f°', logs.get_inaccuracy_tick(logs[e.id], globals.tickcount())),
        correction = string.format('%d:%d°', logs[e.id].correction and 1 or 0, (logs[e.id].feet_yaw < 10 and logs[e.id].feet_yaw > -10) and 0 or logs[e.id].feet_yaw)
    }
    if info.reason == '?' then
        if logs[e.id].total_hits ~= entity.get_prop(me, 'm_totalHitsOnServer') then
            info.reason = 'damage rejection';
        end
    end
    utils.printr(colors.white, '\0')
    logs.printl(
    {colors.gray, "Missed shot at "}, 
    {info.col, info.name}, 
    {colors.gray, " in the "}, 
    {info.col, info.hitgroup}, 
    {colors.gray, " due to "},
    {info.col, info.reason},
    {colors.gray, " ["}, 
    {info.col, info.spread_angle}, 
    {colors.gray, " | "}, 
    {info.col, info.correction}, 
    {colors.gray, "]"},
    {colors.gray, " (hc: "}, 
    {info.col, info.aimed_hitchance }, 
    {colors.gray, " | safety: "}, 
    {info.col, logs[e.id].safety},
    {colors.gray, " | backtrack: "},
    {info.col, logs[e.id].history.."t"}, 
    {colors.gray, " | flags: "}, 
    {info.col, info.flags},
    {colors.gray, ")"})
end
indicate.cross = function()
    local screen = utils.get_screen()
    local lplayer = entity.get_local_player()
    local is_scoped = entity.get_prop(lplayer, "m_bIsScoped") ~= 0
    if ui.get(tabs["Visuals"].indicators[1]) then
        --print(is_scoped)
        local weight, height = renderer.measure_text("-", "EXP.DEV")
        renderer.text(is_scoped and screen.x*0.5 + weight*0.5 or screen.x*0.5, screen.y*0.5 + height , colors.white[1], colors.white[2], colors.white[3], 255, "-c", 0, "EXP.DEV")
    end
end
renderer.world_circle = function(origin, size, color)
    if origin[1] == nil then return end

    local last_point = nil

    for i = 0, 360, 5 do
        local new_point = {
            origin[1] - (math.sin(math.rad(i)) * size),
            origin[2] - (math.cos(math.rad(i)) * size),
            origin[3]
        }

        if last_point ~= nil then
            local old_screen_point = {renderer.world_to_screen(last_point[1], last_point[2], last_point[3])}
            local new_screen_point = {renderer.world_to_screen(new_point[1], new_point[2], new_point[3])}

            if old_screen_point[1] ~= nil and new_screen_point[1] ~= nil then 
                renderer.line(old_screen_point[1], old_screen_point[2], new_screen_point[1], new_screen_point[2], color[1], color[2], color[3], color[4])
            end
        end

        last_point = new_point
    end
end
local function paint_nimb()
    if not ui.get(tabs["Visuals"].nimbus[1]) then return end
    local lplayer = entity.get_local_player()
    if not entity.is_alive(lplayer) or not ui.get(visualgui.tperson[2]) then return end
    local pos = {entity.hitbox_position(lplayer, 0)}
    pos[3] = pos[3] + 8
    renderer.world_circle(pos, 5, {ui.get(tabs["Visuals"].nimbus[2])})
    
end
client.set_event_callback("paint", indicate.cross)
client.set_event_callback("paint", paint_nimb)
client.set_event_callback("paint_ui", menu_visible)
client.set_event_callback("aim_fire", logs.on_fire)
client.set_event_callback("aim_hit", logs.on_hit)
client.set_event_callback("aim_miss", logs.on_miss)
client.set_event_callback("pre_render", animfuck)
client.set_event_callback("setup_command", jitterfuck)
client.set_event_callback("paint", aspect_change)
client.set_event_callback("paint", tpdist)
client.set_event_callback("paint", viewmod)
client.set_event_callback("pre_render", ScaleModel)
test = ui.new_checkbox("CONFIG", "Presets", "Test")
tests = ui.new_slider("CONFIG", "Presets", "SEQUENCE", 0, 300, 0, true, nil, 1, nil)
testl = ui.new_slider("CONFIG", "Presets", "LAYER", 0, 12, 0, true, nil, 1, nil)
testw = ui.new_slider("CONFIG", "Presets", "WEIGHT", 0, 1, 0, true, nil, 1, nil)

client.set_event_callback("pre_render", function()
    local lplayer = entity.get_local_player()
    if ui.get(test) then
        local self_index = c_entity.new(lplayer)
        local self_anim_state = self_index:get_anim_state()
        local self_anim_overlay = self_index:get_anim_overlay(ui.get(testl))
        self_anim_overlay.weight = ui.get(testw)
        self_anim_overlay.sequence = ui.get(tests)

        local a = self_anim_overlay.sequence
        print(a)
    end
end)

client.set_event_callback("shutdown", function() 
    aspect_change(true)
    utils.visibleparse(hide, true)
    viewmod(true)
    tpdist(true)
    ScaleModel(true)
end)