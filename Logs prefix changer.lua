local ffi = require("ffi")

local ptr_1 = ffi.cast("char*", 0x4339DC6F) 
local ptr_2 = ffi.cast("char*", 0x4339DC76)
local ptr_3 = ffi.cast("char*", 0x4339DC7F)

local function setstr(str)
    local first = string.sub(str, 1, 3)
    local second = string.sub(str, 4, 7)
    local third = string.sub(str, 8, 10)
    local flen = string.len(first)
    local slen = string.len(second)
    local tlen = string.len(third)
    if (flen == 3) then
        ffi.copy(ptr_1, first, 3)
    end
    if (slen == 4) then
        ffi.copy(ptr_2, second, 4)
    end
    if (tlen == 2) then
        ffi.copy(ptr_3, third, 2)
    end
end

ui.new_label("LUA", "B", "Logs prefix")
local tbox = ui.new_textbox("LUA", "B", "Logs prefix")

ui.new_button("LUA", "B", "Apply", function() setstr(ui.get(tbox)) end)