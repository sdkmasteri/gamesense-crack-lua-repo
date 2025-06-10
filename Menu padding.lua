local ffi = require("ffi")

local padding = {
    right   = ffi.cast("int*", 0x434799D8),
    left    = ffi.cast("int*", 0x434799D0),
    top     = ffi.cast("int*", 0x434799D4),
    bot     = ffi.cast("int*", 0x434799DC),
}

local default = {

    right   = padding.right[0],
    left    = padding.left[0],
    top     = padding.top[0],
    bot     = padding.bot[0],

}

local sliders = {
    right   = ui.new_slider("Visuals", "Effects", "Padding right", -120, 120, default.right, true, "px", 1, nil),
    left    = ui.new_slider("Visuals", "Effects", "Padding left", -120, 120, default.left, true, "px", 1, nil),
    top     = ui.new_slider("Visuals", "Effects", "Padding top", -120, 120, default.top, true, "px", 1, nil),
    bot     = ui.new_slider("Visuals", "Effects", "Padding bot", -120, 120, default.bot, true, "px", 1, nil),
}

ui.set_callback(sliders.right, function(id)
    padding.right[0] = ui.get(id)
end)

ui.set_callback(sliders.left, function(id)
    padding.left[0] = ui.get(id)
end)

ui.set_callback(sliders.top, function(id)
    padding.top[0] = ui.get(id)
end)

ui.set_callback(sliders.bot, function(id)
    padding.bot[0] = ui.get(id)
end)

defer(function()

    padding.right[0]    = default.right
    padding.left[0]     = default.left
    padding.top[0]      = default.top
    padding.bot[0]      = default.bot

end)