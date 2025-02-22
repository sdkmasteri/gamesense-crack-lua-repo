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
local function download_icon(name)
    local file_path = ("csgo/keys/%s.png"):format(name)
    http.get(("https://raw.githubusercontent.com/sdkmasteri/gamesense-crack-lua-repo/refs/heads/main/keys/%s.png"):format(name), function(status, response)
        if not status then
            return error(string.format("Cant load %s icon", name))
        end

        writefile(file_path, response.body)
    end)
end
if not exists("keys") then create_directories("keys", "keys") end
for _, name in pairs({"w", "a", "s", "d", "w_active", "a_active", "s_active", "d_active"}) do
    if not readfile(string.format("csgo/keys/%s.png", name)) then
        download_icon(name)
    end
end
--credits: @sdkamsteri
local enabler = ui.new_checkbox("Visuals", "Other ESP", "Asynckeys")
math.lerp = function(start, end_pos, time) if start == end_pos then return end_pos end local frametime = globals.frametime() * (1/globals.frametime()); time = time * frametime; local val = start + (end_pos - start) * time; if(math.abs(val - end_pos) < 0.01) then return end_pos end return val end

--@region misc render utils
renderer.empty_rect = function(x, y, w, h, r, g, b, a)
    renderer.line(x, y, x+w, y, r, g, b, a)
    renderer.line(x, y+h, x+w, y+h, r, g, b, a)
    renderer.line(x, y, x, y+h, r, g, b, a)
    renderer.line(x+w, y, x+w, y+h, r, g, b, a)
end
local function calcrange(x, y, w, h)
    return {x1 = x, x2 = x+w, y1 = y, y2 = y + h}
end
local function in_range(curs, rect)
    if curs[1] > rect.x1 and curs[1] < rect.x2 and curs[2] > rect.y1 and curs[2] < rect.y2 then return true end
    return false
end
--@region misc render utils end
--@region dragble
local dragble = {}
dragble.group = function(...)
    local args = {...}
    for _, v in pairs(args) do
        if abs[v] == true then
            for _,v in pairs(args) do
                abs[v] = true
            end
        end
    end
end
dragble.empty_rect = function(index, x, y, w, h, r, g, b, a, hover)
    renderer.empty_rect(cursored ~= nil and cursored[index] ~= nil and cursored[index].x or x, cursored ~= nil and cursored[index] ~= nil and cursored[index].y or y, w, h, r, g, b, a)
    local range = calcrange(cursored[index] ~= nil and cursored[index].x or x, cursored[index] ~= nil and cursored[index].y or y, w, h)
    if ui.is_menu_open() then
        if hover == true then
            if in_range(cpos, range) or abs[index] then
                alpha[index] = alpha[index] ~= nil and math.ceil(math.lerp(alpha[index], a*0.5, 0.05)) or 0
            else 
                alpha[index] = alpha[index] ~= nil and math.floor(math.lerp(alpha[index], 0, 0.05)) or 0
            end
            renderer.rectangle(cursored[index] ~= nil and cursored[index].x or x, cursored[index] ~= nil and cursored[index].y or y, w, h, r, g, b, alpha[index])
        end
        if not firstclick and not abs[index] then return {x = cursored ~= nil and cursored[index] ~= nil and cursored[index].x or x, y = cursored ~= nil and cursored[index] ~= nil and cursored[index].y or y} end
        if clicked then
            if in_range(cpos, range) or abs[index] then
                client.exec("-attack")
                abs[index] = true
                cursored[index] = {x = range.x1 + xdelta, y = range.y1 + ydelta}
            end
        else
            abs[index] = false 
        end
    end
    return {x = cursored ~= nil and cursored[index] ~= nil and cursored[index].x or x, y = cursored ~= nil and cursored[index] ~= nil and cursored[index].y or y}
end
dragble.rectangle = function(index, x, y, w, h, r, g, b, a, hover)
    renderer.rectangle(cursored[index] ~= nil and cursored[index].x or x, cursored[index] ~= nil and cursored[index].y or y, w, h, r, g, b, alpha[index]~= nil and ui.is_menu_open() and alpha[index] or a)
    local range = calcrange(cursored[index] ~= nil and cursored[index].x or x, cursored[index] ~= nil and cursored[index].y or y, w, h)
    if ui.is_menu_open() then
        if hover == true then
            if in_range(cpos, range) or abs[index] then
                alpha[index] = alpha[index] ~= nil and math.floor(math.lerp(alpha[index], a*0.5, 0.05)) or 0
            else 
                alpha[index] = alpha[index] ~= nil and math.ceil(math.lerp(alpha[index], a, 0.05)) or 0
            end
            renderer.empty_rect(cursored[index] ~= nil and cursored[index].x or x, cursored[index] ~= nil and cursored[index].y or y, w, h, r, g, b, a - alpha[index])
        end
        if not firstclick and not abs[index] then return end
        if clicked then
            if in_range(cpos, range) or abs[index] then
                client.exec("-attack")
                abs[index] = true
                cursored[index] = {x = range.x1 + xdelta, y = range.y1 + ydelta}
            end
        else
            abs[index] = false 
        end
    end
end
dragble.texture = function(index, texture_id, x, y, w, h, r, g, b, a, mode)
    renderer.texture(texture_id, cursored[index] ~= nil and cursored[index].x or x, cursored[index] ~= nil and cursored[index].y or y, w, h, r, g, b, a, mode and mode or '')
    local range = calcrange(cursored[index] ~= nil and cursored[index].x or x, cursored[index] ~= nil and cursored[index].y or y, w, h)
    if ui.is_menu_open() then
        if not firstclick and not abs[index] then return end
        if clicked then
            if in_range(cpos, range) or abs[index] then
                client.exec("-attack")
                abs[index] = true
                cursored[index] = {x = range.x1 + xdelta, y = range.y1 + ydelta}
            end
        else
            abs[index] = false 
        end
    end
end
client.set_event_callback("paint", function()
    cursored = cursored or {}
    abs = abs or {}
    alpha = alpha or {}
    oldpos = cpos
    cpos = {ui.mouse_position()}
    if oldpos ~= nil then 
        xdelta = cpos[1] - oldpos[1]
        ydelta = cpos[2] - oldpos[2] 
    end
    oldclicked = clicked
    clicked = client.key_state(0x01)
    firstclick = not oldclicked and clicked
end)
--@region dragble end


local alph = {
    ["W"] = 0,
    ["A"] = 0,
    ["S"] = 0,
    ["D"] = 0
}
client.set_event_callback("paint",  function()
    local w_key = renderer.load_png(readfile("csgo/keys/w.png"), 52, 52)
    local w_ac = renderer.load_png(readfile("csgo/keys/w_active.png"), 52, 52)
    local a_key = renderer.load_png(readfile("csgo/keys/a.png"), 52, 52)
    local a_ac = renderer.load_png(readfile("csgo/keys/a_active.png"), 52, 52)
    local s_key = renderer.load_png(readfile("csgo/keys/s.png"), 52, 52)
    local s_ac = renderer.load_png(readfile("csgo/keys/s_active.png"), 52, 52)
    local d_key = renderer.load_png(readfile("csgo/keys/d.png"), 52, 52)
    local d_ac = renderer.load_png(readfile("csgo/keys/d_active.png"), 52, 52)
    if not ui.get(enabler) then return end
    local x, y = client.screen_size()
    local w, h = 100, 100
    renderer.texture(w_key, abc ~= nil and abc.x + 54 or 54, abc ~= nil and abc.y or y*0.5 - 52, 52, 52, 255, 255, 255, 255)
    renderer.texture(a_key, abc ~= nil and abc.x + 1 or 2, abc ~= nil and abc.y + 54 or y*0.5 + 2, 52, 52, 255, 255, 255, 255)
    renderer.texture(s_key, abc ~= nil and abc.x + 54 or 54, abc ~= nil and abc.y + 54 or y*0.5 + 2, 52, 52, 255, 255, 255, 255)
    renderer.texture(d_key, abc ~= nil and abc.x + 109 or 109, abc ~= nil and abc.y + 54 or y*0.5 + 2, 52, 52, 255, 255, 255, 255)
    if client.key_state(0x57) then
        alph["W"] = math.floor(math.lerp(alph["W"], 255, 0.5))
    else
        alph["W"] = math.ceil(math.lerp(alph["W"], 0, 0.5))
    end
    if client.key_state(0x41) then
        alph["A"] = math.floor(math.lerp(alph["A"], 255, 0.5))
    else
        alph["A"] = math.ceil(math.lerp(alph["A"], 0, 0.5))
    end
    if client.key_state(0x53) then
        alph["S"] = math.floor(math.lerp(alph["S"], 255, 0.5))
    else
        alph["S"] = math.ceil(math.lerp(alph["S"], 0, 0.5))
    end
    if client.key_state(0x44) then
        alph["D"] = math.floor(math.lerp(alph["D"], 255, 0.5))
    else
        alph["D"] = math.ceil(math.lerp(alph["D"], 0, 0.5))
    end
    renderer.texture(w_ac, abc ~= nil and abc.x + 54 or 54, abc ~= nil and abc.y or y*0.5 - 52, 52, 52, 255, 255, 255, alph["W"])
    renderer.texture(a_ac, abc ~= nil and abc.x + 1 or 2, abc ~= nil and abc.y + 54 or y*0.5 + 2, 52, 52, 255, 255, 255, alph["A"])
    renderer.texture(s_ac, abc ~= nil and abc.x + 54 or 54, abc ~= nil and abc.y + 54 or y*0.5 + 2, 52, 52, 255, 255, 255, alph["S"])
    renderer.texture(d_ac, abc ~= nil and abc.x + 109 or 109, abc ~= nil and abc.y + 54 or y*0.5 + 2, 52, 52, 255, 255, 255, alph["D"])
    if ui.is_menu_open() then
        abc = dragble.empty_rect("#RECT", 0, y*0.5 -54, 163, 109, 255, 255, 255, 255, false)
    end

end)
