ui.new_label("Lua", "A", "Custom Peek")
local ap = ui.new_hotkey("Lua", "A", "Custom PeekE", true, 0x00)
ui.new_label("Lua", "A", "Custom Peek Color")
local colr = ui.new_color_picker("Lua", "A", "Custom Peek Color Peeker", 255, 255, 255, 255)
local ad = ui.new_slider("Lua", "A", "Quick Peek Distance", 16, 201, 100, true, "in", 1, {[201] = "inf"})
local speed = ui.new_slider("Lua", "A", "Animation Speed", 1, 100, 50, true, "%", 1, nil)
math.lerp = function(start, end_pos, time) if start == end_pos then return end_pos end local frametime = globals.frametime() * (1/globals.frametime()); time = time * frametime; local val = start + (end_pos - start) * time; if(math.abs(val - end_pos) < 0.01) then return end_pos end return val end

local function distance(origin1, origin2)
    return math.abs(origin2[1] - origin1[1]) + math.abs(origin2[2] - origin1[2]) -- d=√((x_2-x_1)²+(y_2-y_1)²)
end
local function delta(origin1, origin2, dist)
    local delt = {origin2[1] - origin1[1], origin2[2] - origin1[2]}
    local res = {0, 0}
    if delt[1] > dist then
        res[1] = delt[1] - dist
    elseif delt[1] < -dist then
        res[1] = delt[1] + dist
    end
    if delt[2] > dist then
        res[2] = delt[2] - dist
    elseif delt[2] < -dist then
        res[2] = delt[2] + dist
    end
    return res
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
renderer.world_filled_circle = function(origin, size, color)
    if origin[1] == nil then return end

    local center_screen_point = {renderer.world_to_screen(origin[1], origin[2], origin[3])}
    if center_screen_point[1] == nil then return end 

    local last_point = nil

    for i = 0, 360, 5 do
        local new_point = {
            origin[1] - (math.sin(math.rad(i)) * size),
            origin[2] - (math.cos(math.rad(i)) * size),
            origin[3]
        }

        if last_point ~= nil then
            local new_screen_point = {renderer.world_to_screen(new_point[1], new_point[2], new_point[3])}
            local last_screen_point = {renderer.world_to_screen(last_point[1], last_point[2], last_point[3])}
            if new_screen_point[1] ~= nil and last_screen_point[1] ~= nil then
                renderer.triangle(center_screen_point[1], center_screen_point[2], last_screen_point[1], last_screen_point[2], new_screen_point[1], new_screen_point[2], color[1], color[2], color[3], color[4])
            end
        end

        last_point = new_point
    end
end
local i = 0
local pos
local dist
local rad = 0
client.set_event_callback("paint", function()
    local lplayer = entity.get_local_player()
    local col = {ui.get(colr)}
    local cpos =  {entity.get_origin(lplayer)}
    local aspeed = ui.get(speed)*0.01
    col[4] = col[4]*0.5
    if ui.get(ap) then
        if i < 1 then
            i = 1
            pos = cpos
        end
        dist = distance(pos, cpos)
        local delt = delta(pos, cpos, ui.get(ad))
        if ui.get(ad) < 201 and dist >= ui.get(ad) then
            pos = {pos[1] + delt[1], pos[2] + delt[2], pos[3]}
        end
        rad = math.ceil(math.lerp(rad, 15, aspeed))
    else
        rad = math.floor(math.lerp(rad, 0, aspeed))
        i = 0
    end
    if pos ~= nil then
        renderer.world_filled_circle(pos, rad, col)
        col[4] = col[4]*2
        renderer.world_circle(pos, rad, col)
    end
end)
local retr = false
client.set_event_callback("weapon_fire", function(e)
    if client.userid_to_entindex(e.userid) == entity.get_local_player() and ui.get(ap) then
        retr = true
    end
end)
client.set_event_callback("setup_command", function(cmd)
    local lplayer = entity.get_local_player()
    local lpos = {entity.get_origin(lplayer)}
    if retr and ui.get(ap) then 
        local yaw = cmd.yaw
        local vecforward = {lpos[1] - pos[1], lpos[2] - pos[2], lpos[3] - pos[2]}
        local translvel = {
            vecforward[1] * math.cos(cmd.yaw/180 * math.pi) + vecforward[1] * math.sin(cmd.yaw/180 * math.pi),
            vecforward[2] * math.cos(cmd.yaw/180 * math.pi) - vecforward[1] * math.sin(yaw/180 * math.pi),
            vecforward[3]
            }
        cmd.forwardmove = -translvel[1] * 20
        cmd.sidemove = translvel[2] * 20
        if dist < 2 then
            retr = false
        end
    end
end)