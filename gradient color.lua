local ffi = require("ffi")

local gradientptr1 = ffi.cast("char*", 0x43384950)
local gradientptr2 = ffi.cast("char*", 0x43384940)
local gradientptr3 = ffi.cast("char*", 0x4338496D)

local chararr = ffi.new("char[4]")
ui.new_label("LUA", "B", "Gradient 1")
local color1 = ui.new_color_picker("LUA", "B", "Gradient 1", gradientptr1[0], gradientptr1[1], gradientptr1[2], gradientptr1[3])
ui.new_label("LUA", "B", "Gradient 2")
local color2 = ui.new_color_picker("LUA", "B", "Gradient 2", gradientptr2[0], gradientptr2[1], gradientptr2[2], gradientptr2[3])
ui.new_label("LUA", "B", "Gradient 3")
local color3 = ui.new_color_picker("LUA", "B", "Gradient 3", gradientptr3[0], gradientptr3[1], gradientptr3[2], gradientptr3[3])

local function setcharrar(col)
    for i=0, 3 do
        chararr[i] = col[i+1]
    end
end

ui.set_callback(color1, function(id)
    local chcol = {ui.get(id)}
    setcharrar(chcol)
    ffi.copy(gradientptr1, chararr, 4)
end)

ui.set_callback(color2, function(id)
    local chcol = {ui.get(id)}
    setcharrar(chcol)
    ffi.copy(gradientptr2, chararr, 4)
end)

ui.set_callback(color3, function(id)
    local chcol = {ui.get(id)}
    setcharrar(chcol)
    ffi.copy(gradientptr3, chararr, 4)
end)