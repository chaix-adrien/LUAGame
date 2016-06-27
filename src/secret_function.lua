function rotate_pos(x, y, r, sprite)
	local new_x = (math.cos(-r) * tile_sizex + math.sin(-r) * tile_sizey) / 2
	local new_y = (math.cos(-r) * tile_sizey - math.sin(-r) * tile_sizex) / 2
	local tmp_x = x  - new_x
	local tmp_y = y - new_y
	return tmp_x, tmp_y
end

function draw_shield(player)
	if (player["shield"] and player["shield"] == 1 and player["shield_life"] > 0) then
		if (player["shield_life"] > 2) then love.graphics.setColor(0, 0, 255, 255)
		elseif (player["shield_life"] > 1) then love.graphics.setColor(50, 100, 255, 255)
		elseif (player["shield_life"] > 0) then love.graphics.setColor(100, 200, 255, 255)
		end
		px, py = map_to_pix(player.pos_x, player.pos_y)
		love.graphics.setLineWidth(6)
		love.graphics.arc("line", "open", px, py, tile_sizey / 1.5, player["r"] - shield_size - rot, player["r"] + shield_size - rot, 20)
		love.graphics.setLineWidth(2)
		set_laser_color(player)
		return (1)
	else
		return (0)
	end
end

function set_laser_color(value)
	love.graphics.setColor(190, 190, 190, 255)
	if (value["cooldown"] and value["cooldown"] > 0) then love.graphics.setColor(0,0,0,0)
	elseif (value["shoot"] == 1) then
		love.graphics.setColor(255, 0, 0, 255)
	elseif (value["ammo"]) then
		if value["ammo"] == 3 then love.graphics.setColor(155, 155, 100, 255)
		elseif value["ammo"] == 2 then love.graphics.setColor(255, 155, 0, 255)
		elseif value["ammo"] == 1 then love.graphics.setColor(255, 0, 50, 255)
		end
	end
end

function shoot_on_mobs(player, px, py, call_func)
	for i, mob_type in pairs(mobs) do
		for j, mob in pairs(mob_type) do
			if (is_on_mob(px, py, mob) == 1) then
				if (call_func == 1) then
					mob.shooted_on(player, mob, i, j)
				end			
				return mob
			end
		end
	end
	return nil
end

function draw_fire(player)
	if (player["shield"] and player["shield_life"]) then
		draw_shield(player)
	end
	if (player["ammo"] > 0 and player["cooldown"] <= 0 and not (player["shield"] and player["shield"] ~= 0)) then
		tmp_posx = player.pos_x
		tmp_posy = player.pos_y
		vec_x, vec_y = get_view_vector(player.r, 10)
		set_laser_color(player)
		local hit = 0
		repeat
			hit = 0
			for i, target in pairs(players) do
				if ((player["name"] ~= target["name"]) and math.pow(tmp_posx - (target["pos_x"] - 1) * tile_sizex, 2)
					+ math.pow(tmp_posy - (target["pos_y"] - 1) * tile_sizey, 2) < math.pow(tile_sizey / 2, 2)) then
					hit = 1
					break
				end
			end
			if (shoot_on_mobs(player, tmp_posx, tmp_posy, 0) ~= nil) then
				hit = 1
			end
			if (hit == 1 or map[math.floor(tmp_posy)][math.floor(tmp_posx)]["crossable"] == 0) then
				break
			end
			pix, piy = map_to_pix(tmp_posx, tmp_posy)			
			love.graphics.rectangle("fill", pix, piy, 7, 7)	
			tmp_posx = tmp_posx + vec_x
			tmp_posy = tmp_posy + vec_y
		until (tmp_posx < 1 or tmp_posx > x_fields + 1 or
		tmp_posy < 1 or tmp_posy > y_fields + 1)
		love.graphics.setColor(255, 255, 255, 255)
	end
end

--
--
--
--

function cut_on_mobs(player, pos)
	for i, mob_type in pairs(mobs) do
		for j, mob in pairs(mob_type) do
			if (is_on_mob(pos.x, pos.y, mob) == 1) then
				mob.cuted_on(player, mob, i, j)
			end
		end
	end
end

function cut_attack(player)
	for i, target in pairs(players) do
		if (target["name"] ~= player["name"] and
			math.sqrt(math.pow(target.pos_x - player.pos_x, 2) + math.pow(target.pos_y - player.pos_y, 2)) < 1) then
			target["life"] = target["life"] - 10
			target["no_hit"] = 2
			cut_sound:play()
		end
	end
	map[math.floor(player["pos_y"])][math.floor(player["pos_x"])]["cut_on"](j2, i2, player)
	local float = {x = player["pos_x"] + 0.5 * math.cos(player["r"] - math.pi / 2),
	y = player["pos_y"] + 0.5 * math.sin(player["r"] - math.pi / 2)}
	local tmp_x = math.floor(float.x)
	local tmp_y = math.floor(float.y)
	cut_on_mobs(player, float)
	if (tmp_x > 0 and tmp_y > 0 and tmp_x <= x_fields and tmp_y <= y_fields 
		and (tmp_x ~= math.floor(player["pos_x"]) or tmp_y ~= math.floor(player["pos_y"]))) then
		map[tmp_y][tmp_x]["cut_on"](tmp_x, tmp_y, player)
	end
	player["cut_state"] = 1
end

function check_shield(player, vec_x, vec_y)
	local player_x = 0
	local player_y  = 0
	player_x, player_y = get_view_vector(player.r, 1)
	angle = math.atan2(-vec_y, -vec_x) - math.atan2(player_y, player_x)
	if (player["shield"] and player["shield"] == 1 and math.abs(angle) <= shield_size) then
		return 1
	else
		return 0
	end
end

function fire_on_powerups(x, y)
	for i, pu in pairs(powerups) do
		if (x == pu.x and y == pu.y) then
			-- TODO sound break powerup / sound brick cassé
			table.remove(powerups, i)
		end
	end
end

function fire(pos, r, damage, player) -- TODO param damage if touch, gerer les pdv enelvé aux joueurs ici
	local tmp_posx = pos.x
	local tmp_posy = pos.y
	vec_x, vec_y = get_view_vector(r, 10)
	repeat
		x = math.floor(tmp_posx)
		y = math.floor(tmp_posy)
		for i, target in pairs(players) do
			if (not (player and player.name == target.name) and math.pow(tmp_posx - target.pos_x, 2)
				+ math.pow(tmp_posy - target.pos_y, 2) < math.pow(0.5, 2)) then
				if (target.shield and check_shield(target, vec_x, vec_y) == 1) then
					target.shield_life = target.shield_life - 1
					if (target.shield_life > 0) then
						shield_sound:play()
					else
						shield_break_sound:play()
					end
					table.insert(impact, {pos_x = tmp_posx, pos_y = tmp_posy, frame = 15, sprite = sprite_impact})
					return nil					
				elseif (target.no_hit <= 0) then
					if (player) then
						color = player.color
					else
						color = {255, 255, 255, 255}
					end
					table.insert(impact, {pos_x = target.pos_x, pos_y = target.pos_y, frame = 15, sprite = sprite_skull, color = color})
				end
				return target, 0
			end
		end
		fire_on_powerups(x, y)
		if (player) then
			local mob = shoot_on_mobs(player, tmp_posx, tmp_posy, 1)
			if (mob) then
				table.insert(impact, {pos_x = tmp_posx, pos_y = tmp_posy, frame = 15, sprite = sprite_impact, color = player.color}) --change sprite
				return mob
			end
		end
		if (map[y][x]["crossable"] == 0) then
			map[y][x]["shooted_on"](x, y, player)
			if (player) then
				colors = player.color
			else
				colors = {255, 255, 255, 255}
			end
			table.insert(impact, {pos_x = tmp_posx, pos_y = tmp_posy, frame = 15, sprite = sprite_impact, color = colors})
			break
		end
		tmp_posx = tmp_posx + vec_x
		tmp_posy = tmp_posy + vec_y
	until (tmp_posx < 1 or tmp_posx > x_fields + 1 or
	tmp_posy < 1 or tmp_posy > y_fields + 1)
	return nil, 0
end

function shoot(pos, r, damage, player) -- TODO : passer sound en param
	target = fire(pos, r, damage, player)
    if (player) then
		player.ammo = player.ammo - 1
		player["shoot"] = 1
	end
	if (target and not (target.no_hit and target.no_hit > 0)) then
		laser2:play()
		if (target.life) then
			target.life = target.life - damage
		end
		if (target.no_hit) then
			target["no_hit"] = 2
		end
	else
		laser:play()
	end
end