local ffi = require("ffi")

local buffer = ffi.new("char[?]", 0x1D)
local ogbytes = ffi.new("char[?]", 0x1D)
local ptr = ffi.cast("char*", 0x433AC04B)
ffi.copy(ogbytes, ptr, 0x1D)
ffi.copy(buffer, ogbytes, 0x1D)
ffi.fill(buffer, 0x18, 0x90)
buffer[0x18] = 0xE9
local enabled = ui.new_checkbox("RAGE", "Other", "\aFF0000FFUnsafe Charge")

ui.set_callback(enabled, function(id)
    if ui.get(id) then
        ffi.copy(ptr, buffer, 0x1D)
    else
        ffi.copy(ptr, ogbytes, 0x1D)
    end
end)