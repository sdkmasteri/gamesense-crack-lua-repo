local ffi = require("ffi")

local base = ffi.cast("int*", 0x43479930)

local fontsize = ffi.cast("float*", base[0] + 0x100)
local defsize = fontsize[0]
ui.set_callback(ui.new_slider("Config", "Presets", "Font Size", 0, 500, fontsize[0]*100, true, "%", 1, nil), function(id)
    fontsize[0] = ui.get(id)*0.01
end)

defer(function() fontsize[0] = defsize end)
