--coded by sakenzo
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
        if not firstclick and not abs[index] then return end
        if clicked then
            if in_range(cpos, range) or abs[index] then
                abs[index] = true
                cursored[index] = {x = range.x1 + xdelta, y = range.y1 + ydelta}
            end
        else
            abs[index] = false 
        end
    end
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
client.set_event_callback("paint",  function()
    if not ui.get(enabler) then return end
    local x, y = client.screen_size()
    local w, h = 100, 100
    dragble.empty_rect("#1", 0, y*0.5, w, h, 255, 255, 255, 255, true)
    dragble.empty_rect("#2", 100, 0, w, h, 255,255,0,255, true)
    --dragble.group("#1", "#2")
    dragble.rectangle("#3", 500, 500, w, h, 0, 255,255,255, true)
end)
