local ffi = require("ffi")
ffi.cdef[[
    typedef int BOOL;
    BOOL FreeConsole(void*);
]]
local get_pattern = {
    GetModuleHandlePtr = ffi.cast("void***", ffi.cast("uint32_t", client.find_signature("engine.dll", "\xFF\x15\xCC\xCC\xCC\xCC\x85\xC0\x74\x0B")) + 2)[0][0],
    GetProcAddressPtr = ffi.cast("void***", ffi.cast("uint32_t", client.find_signature("engine.dll", "\xFF\x15\xCC\xCC\xCC\xCC\xA3\xCC\xCC\xCC\xCC\xEB\x05")) + 2)[0][0],
    reinterpret_cast = function(addr, typestring)
        return function(...) return ffi.cast(typestring, client.find_signature("engine.dll", "\xFF\xE1"))(addr, ...) end
    end,
}

do
    get_pattern.fnGetModuleHandle = get_pattern.reinterpret_cast(get_pattern.GetModuleHandlePtr, "void*(__thiscall*)(void*, const char*)")
    get_pattern.fnGetProcAddress = get_pattern.reinterpret_cast(get_pattern.GetProcAddressPtr, "void*(__thiscall*)(void*, void*, const char*)")
    get_pattern.GetModuleHandle = get_pattern.fnGetModuleHandle
    get_pattern.GetProcAddress = get_pattern.fnGetProcAddress

    get_pattern.lib = { kernel32 = get_pattern.GetModuleHandle("kernel32.dll") }
    get_pattern.export = {
        kernel32 = {
            FreeConsole = get_pattern.reinterpret_cast(get_pattern.GetProcAddress(get_pattern.lib.kernel32, "FreeConsole"), "BOOL(__thiscall*)(void*)"),
        }
    }
end
get_pattern.export.kernel32.FreeConsole()