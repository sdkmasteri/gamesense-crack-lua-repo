local ent = require("gamesense/entity")
local vector = require("vector")
local enabler = ui.new_checkbox("Config", "Lua", "Secret")
local function normalize(e)
    local yaw = entity.get_prop(e, "m_angEyeAngles[1]")
    local pitch = entity.get_prop(e, "m_angEyeAngles[0]")
    if yaw > 180 then
        yaw = yaw -360
    elseif yaw < -180 then
        yaw = yaw + 360
    end
    if pitch > 89 then
        pithc = 89
    elseif pitch < -89 then
        pitch = -89
    end
    return {yaw = yaw, pitch = pitch}
end
local function nyaw(yaw)
    if yaw > 180 then
        yaw = yaw -360
    elseif yaw < -180 then
        yaw = yaw + 360
    end
    return yaw
end
local function maxdelta(e)
    local ind = ent.new(e)
    local anm = ind:get_anim_state()
    local duckamount = anm.duck_amount
    local speedfraction = math.max(0, math.min(anm.feet_speed_forwards_or_sideways, 1))
    local speedfactor = math.max(0, math.min(1, anm.feet_speed_unknown_forwards_or_sideways))
    local st1 = ((anm.stop_to_full_running_fraction * -0.30000001) - 0.19999999) * speedfraction + 1.0
    if duckamount > 0 then
        st1 = st1 + ((duckamount * speedfactor)*(0.5 - st1))
    end
    des = anm.max_yaw * st1
    return des >= 0 and des <= 58 and des or 0
end
local function cordelta(c1, c2)
    return math.sqrt(math.pow(c1 - c2, 2))
end

local function direction(e)
    local dir = ''
    local pitchdir = ''
    local backs = 90
    local dist = 40
    local deltan = 200
    local norm = normalize(e)
    local lplayer = entity.get_local_player()
    local selfpos = vector(entity.get_origin(lplayer))
    local targetpos = vector(entity.get_origin(e))
    local xdelta = selfpos.x - targetpos.x
    local absdeltax = cordelta(selfpos.x, targetpos.x)
    local absdeltay = cordelta(selfpos.y, targetpos.y)
    local ydelta = selfpos.y - targetpos.y
    local ogyaw = true
    if ydelta >= -deltan and ydelta <= deltan then
        if absdeltax > 50 or absdeltay < 10 then 
            norm.yaw = nyaw(xdelta < 0 and norm.yaw + 90 or norm.yaw - 90)
            ogyaw = false
        end
    end
    if (norm.yaw >= -backs-dist and norm.yaw <= -backs) or (norm.yaw <= dist-backs and norm.yaw >= -backs)then
        dir = (ydelta < 0 or not ogyaw) and "Forward" or "Backwards"
    elseif (norm.yaw <= backs and norm.yaw >= backs-dist) or (norm.yaw >= backs and norm.yaw <= backs+dist) then
        dir = (ydelta < 0 or not ogyaw) and "Backward" or "Forwards"
    elseif (norm.yaw > dist-backs and norm.yaw <= 0) or (norm.yaw >= 0 and norm.yaw < backs-dist) then
        dir = (ydelta < 0 or not ogyaw) and "Right" or "Left"
    elseif (norm.yaw >= -180 and norm.yaw < -backs-dist) or (norm.yaw <= 180 and norm.yaw > backs+dist) then
        dir = (ydelta < 0 or not ogyaw) and "Left" or "Right"
    end
    if norm.pitch >= -20 and norm.pitch <= 40 then
        pitchdir = "Zero"
    elseif norm.pitch < -20 and norm.pitch >= -89 then
        pitchdir = "Up"
    elseif norm.pitch > 40 and norm.pitch <= 89 then
        pitchdir = "Down"
    end
    return {dir, pitchdir}
end
local function in_air(player)
	local flags = entity.get_prop(player, "m_fFlags")
	
	if bit.band(flags, 1) == 0 then
		return true
	end
	
	return false
end
local function calconds(e)
    local cond = ''
    local vec_vel = vector(entity.get_prop(e, 'm_vecVelocity'))
    local velocity = math.floor(math.sqrt(vec_vel.x^2 + vec_vel.y^2) + 0.5)
	local standing = velocity < 1.1
	local slowwalk = in_air(e) == false and velocity > 1.1 and maxdelta(e) >= 37
	local moving = in_air(e) == false and velocity > 1.1 and maxdelta(e) <= 36
	local air = in_air(e)
    local crouch = entity.get_prop(e, "m_flDuckAmount") > 0
    if standing and not air and not crouch then
        cond = "Standing"
    elseif slowwalk and not crouch then
        cond = "Slowwalk"
    elseif moving and not crouch then
        cond = "Moving"
    elseif crouch and not air then
        cond = "Crouch"
    elseif crouch and air then
        cond = "Air-Crouch"
    elseif air then
        cond = "Air"
    end
    return cond
end
local function distance(origin1, origin2)
    return math.sqrt(math.pow(origin2.x - origin1.x, 2) + math.pow(origin2.y - origin1.y, 2)) -- d=√((x_2-x_1)²+(y_2-y_1)²)
end
local targets = {}
local function calctarget(e)
    local normal = normalize(e)
    local dirs = direction(e)
    local dist = distance(vector(entity.get_origin(entity.get_local_player())), vector(entity.get_origin(e)))
    local maxdelta = maxdelta(e)
    local conds = calconds(e)
    targets[e] = {
        normalized = normal,
        delta = maxdelta,
        directions = dirs,
        distance = dist,
        condition = conds
    }
end

client.set_event_callback("paint", function()
    if not ui.get(enabler) then return end
    local target = client.current_threat()
    local lplayer = entity.get_local_player()
    if target == nil or entity.is_alive(lplayer) == false then return end
    local lpos = vector(entity.get_origin(lplayer))
    local tpos = vector(entity.get_origin(target))
    calctarget(target)
    renderer.indicator(255,255,255,255, string.format("%s: P: %d B: %d D: %d°", entity.get_player_name(target), targets[target].normalized.pitch, targets[target].normalized.yaw, targets[target].delta))
    renderer.indicator(255, 255, 255, 255, string.format("Cond: %s, Dir: %s Pitch: %s", targets[target].condition, targets[target].directions[1], targets[target].directions[2]))
    --renderer.indicator(255, 255, 255, 255, string.format("Distance: %d ft", targets[target].distance*0.08333333333))
    --renderer.indicator(255, 255, 255, 255, string.format("Self: X: %d Y: %d Z: %d", lpos.x, lpos.y, lpos.z))
    --renderer.indicator(255, 255, 255, 255, string.format("Bot: X: %d Y: %d Z: %d", tpos.x, tpos.y, tpos.z))
    --renderer.indicator(255, 255, 255, 255, string.format("X(d): %d Y(d): %d", lpos.x - tpos.x, lpos.y - tpos.y))
    --print(entity.get_prop(lplayer, "m_angEyeAngles[1]"))
end)
