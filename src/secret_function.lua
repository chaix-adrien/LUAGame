function rotate_pos(x, y, r, sprite)
	local new_x = (math.cos(-r) * (screen_w / x_fields) + math.sin(-r) * (screen_h / y_fields)) / 2
	local new_y = (math.cos(-r) * (screen_h / y_fields) - math.sin(-r) * (screen_w / x_fields)) / 2
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
		love.graphics.setLineWidth(6)
		love.graphics.arc("line", "open", (player["pos_x"] - 1) * tile_sizex, (player["pos_y"] - 1) * tile_sizey, tile_sizey / 1.5, player["r"] - shield_size - rot, player["r"] + shield_size - rot, 20)
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
	px = (px / tile_sizex) + 1
	py = (py / tile_sizey) + 1
	for i, mob_type in pairs(mobs) do
		for j, mob in pairs(mob_type) do
			if (is_on_mob(px, py, mob) == 1) then
				if (call_func == 1) then
					mob.shooted_on(player, mob, i, j)
				end			
				return (1)
			end
		end
	end
	return (0)
end

function draw_fire(player)
	if (player["shield"] and player["shield_life"]) then
		draw_shield(player)
	end
	if (player["ammo"] > 0 and player["cooldown"] <= 0 and not (player["shield"] and player["shield"] ~= 0)) then
		tmp_posx, tmp_posy = map_to_pixel(player["pos_x"], player["pos_y"])
		vec_x, vec_y = get_view_vector(player)
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
			if (shoot_on_mobs(player, tmp_posx, tmp_posy, 0) == 1) then
				hit = 1
			end
			if (hit == 1 or map[math.floor(tmp_posy /tile_sizey) + 1][math.floor(tmp_posx / tile_sizex) + 1]["crossable"] == 0) then
				break
			end
			love.graphics.rectangle("fill", tmp_posx, tmp_posy, 7, 7)	
			tmp_posx = tmp_posx + vec_x
			tmp_posy = tmp_posy + vec_y
		until (tmp_posx < 0 or tmp_posx >= screen_w or
		tmp_posy < 0 or tmp_posy >= screen_h)
		love.graphics.setColor(255, 255, 255, 255)
	end
end

--
--
--
--

function cut_attack(player)
	j2, i2 = map_to_pixel(player["pos_x"], player["pos_y"])
	for i, target in pairs(players) do
		j, i = map_to_pixel(target["pos_x"], target["pos_y"])
		if (target["name"] ~= player["name"] and
			math.sqrt(math.pow(j - j2, 2) + math.pow(i - i2, 2)) < tile_sizey) then
			target["life"] = target["life"] - 10
			target["no_hit"] = 2
			cut_sound:play()
		end
	end
	map[math.floor(player["pos_y"])][math.floor(player["pos_x"])]["cut_on"](j2, i2, player)
	local tmp_x = math.floor(player["pos_x"] + 0.5 * math.cos(player["r"] - math.pi / 2))
	local tmp_y = math.floor(player["pos_y"] + 0.5 * math.sin(player["r"] - math.pi / 2))
	if (tmp_x > 0 and tmp_y > 0 and tmp_x <= x_fields and tmp_y <= y_fields 
		and (tmp_x ~= math.floor(player["pos_x"]) or tmp_y ~= math.floor(player["pos_y"]))) then
		map[tmp_y][tmp_x]["cut_on"](tmp_x, tmp_y, player)
	end
	player["cut_state"] = 1
end

function check_shield(player, vec_x, vec_y)
	local player_x = 0
	local player_y  = 0
	player_x, player_y = get_view_vector(player)
	angle = math.atan2(-vec_y, -vec_x) - math.atan2(player_y, player_x)
	if (player["shield"] and player["shield"] == 1 and math.abs(angle) <= shield_size) then
		return 1
	else
		return 0
	end
end

function fire_on_powerups(x, y, player)
	for i, pu in pairs(powerups) do
		if (x == pu.x and y == pu.y) then
			-- TODO sound break powerup
			table.remove(powerups, i)
		end
	end
end

function get_fire(value)
	local tmp_posx = (value["pos_x"] - 1) * tile_sizex
	local tmp_posy = (value["pos_y"] - 1) * tile_sizey
	vec_x, vec_y = get_view_vector(value)
	repeat
		x = math.floor(tmp_posx / tile_sizex) + 1
		y = math.floor(tmp_posy / tile_sizey) + 1
		for i, player in pairs(players) do
			if ((value["name"] ~= player["name"]) and math.pow(tmp_posx - (player["pos_x"] - 1) * tile_sizex, 2)
				+ math.pow(tmp_posy - (player["pos_y"] - 1) * tile_sizey, 2) < math.pow(tile_sizey / 2, 2)) then
				if (player["shield"] and check_shield(player, vec_x, vec_y) == 1) then
					player["shield_life"] = player["shield_life"] - 1
					if (player["shield_life"] > 0) then
						shield_sound:play()
					else
						shield_break_sound:play()
					end
					if (sprite_impact) then
						table.insert(impact, {pos_x = tmp_posx, pos_y = tmp_posy, frame = 15, sprite = sprite_impact})
					end
					return player, 1					
				elseif (player["no_hit"] <= 0 and sprite_skull) then
					table.insert(impact, {pos_x = (player["pos_x"] - 1) * tile_sizex, pos_y = (player["pos_y"] - 1) * tile_sizey, frame = 15, sprite = sprite_skull, color = player.color})
				end
				return player, 0
			end
		end
		fire_on_powerups(x, y, value)
		if (shoot_on_mobs(value, tmp_posx, tmp_posy, 1) == 1) then
			table.insert(impact, {pos_x = tmp_posx, pos_y = tmp_posy, frame = 15, sprite = sprite_impact, color = value.color}) --change sprite
			break
		end
		if (map[y][x]["crossable"] == 0) then
			map[y][x]["shooted_on"](x, y, value)
			if (sprite_impact) then
				table.insert(impact, {pos_x = tmp_posx, pos_y = tmp_posy, frame = 15, sprite = sprite_impact, color = value.color})
			end
			break
		end
		repeat
			tmp_posx = tmp_posx + vec_x
			tmp_posy = tmp_posy + vec_y
		until (math.floor(tmp_posx * tile_sizex) + 1 ~= x or math.floor(tmp_posy * tile_sizey) + 1 ~= y)
	until (tmp_posx < 0 or tmp_posx > screen_w or
	tmp_posy < 0 or tmp_posy > screen_h)
	return nil, 0
end