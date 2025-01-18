--credist: @dave8x3
local ffi = require("ffi")
local http = require("gamesense/http")
local filesystem_interface = ffi.cast(ffi.typeof("void***"), client.create_interface("filesystem_stdio.dll", "VFileSystem017"))
local filesystem_create_directories = ffi.cast("void (__thiscall*)(void*, const char*, const char*)", filesystem_interface[0][22])
local filesystem_find = ffi.cast("const char* (__thiscall*)(void*, const char*, int*)", filesystem_interface[0][32])
local function create_directories(file, path_id)
    filesystem_create_directories(filesystem_interface, file, path_id)
end
local exists = function(file)
    local int_ptr = ffi.new("int[1]")
    local res = filesystem_find(filesystem_interface, file, int_ptr)
    if res == ffi.NULL then
        return nil
    end

    return int_ptr, ffi.string(res)
end
local function download_res(name, file_path)
    http.get(("https://raw.githubusercontent.com/sdkmasteri/gamesense-crack-lua-repo/refs/heads/main/trash/%s"):format(name), function(status, response)
        if not status then
            return error(string.format("Cant load %s", name))
        end
        writefile(file_path, response.body)
    end)
end
if not exists("materials/trash1") then create_directories("materials/trash1", "materials/trash1") end
if not exists("sound/trash") then create_directories("sound/trash", "sound/trash") end
for key, value in pairs({["iconic.png"] = "csgo/materials/trash1/iconic.png", ["bog.mp3"] = "csgo/sound/trash/bog.mp3"}) do
    if not readfile(value) then
        download_res(key, value)
    end
end
--credits: @sdkmasteri
local vgui = ffi.cast(ffi.typeof("void***"), client.create_interface("vguimatsurface.dll", "VGUI_Surface031"))
local playsound = ffi.cast("void(__thiscall*)(void*, const char*)", vgui[0][82])
math.lerp = function(start, end_pos, time) if start == end_pos then return end_pos end local frametime = globals.frametime() * (1/globals.frametime()); time = time * frametime; local val = start + (end_pos - start) * time; if(math.abs(val - end_pos) < 0.01) then return end_pos end return val end
local init = false
local again = false

local alph = 255
client.set_event_callback("paint", function()
    local a = renderer.load_png(readfile("csgo/materials/trash1/iconic.png"), 210, 278)
    local x, y = client.screen_size()
    if init then
        if again then
            alph = 255
            again = false
        end
        if alph == 0 then alph = 255 end
        renderer.texture(a, x*0.5 - 105, y*0.5 - 139, 210, 278, 255, 255, 255, alph)
        alph = math.floor(math.lerp(alph, 0, 0.05))
        if alph == 0 then init = false end
    end
end)
client.set_event_callback("player_hurt", function(e)
    if client.userid_to_entindex(e.userid) == entity.get_local_player() then
        if init == true then 
            again = true
            client.exec("stopsound")
        end
        init = true
        playsound(vgui, "trash/bog.mp3")
    end
end)