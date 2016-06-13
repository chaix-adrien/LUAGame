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

function draw_fire()
	if (impact) then
		for i, value in pairs(players) do
			draw_shield(value)
			if (value["ammo"] > 0 and value["cooldown"] == 0 and value["shield"] == 0) then
				tmp_posx = (value["pos_x"] - 1) * tile_sizex
				tmp_posy = (value["pos_y"] - 1) * tile_sizey
				vec_x, vec_y = get_view_vector(value)
				set_laser_color(value)
				repeat
					local hit = 0
					for i, player in pairs(players) do
					-- if shield
						if ((value["name"] ~= player["name"]) and math.pow(tmp_posx - (player["pos_x"] - 1) * tile_sizex, 2)
							+ math.pow(tmp_posy - (player["pos_y"] - 1) * tile_sizey, 2) < math.pow(tile_sizey / 2, 2)) then
							love.graphics.rectangle("fill", tmp_posx, tmp_posy, 7, 7)
							hit = 1
							break
						end
					end
					if (hit == 1 or blocks[map[math.floor(tmp_posy / tile_sizey) + 1][math.floor(tmp_posx / tile_sizex) + 1]]["crossable"] == 0) then
						break
					end
					love.graphics.rectangle("fill", tmp_posx, tmp_posy, 7, 7)	
					tmp_posx = tmp_posx + vec_x
					tmp_posy = tmp_posy + vec_y
				until (tmp_posx < 0 or tmp_posx > screen_w or
				tmp_posy < 0 or tmp_posy > screen_h)
				love.graphics.setColor(255, 255, 255, 255)
			end
		end
	end
end

--
--
--
--

function cut_attack(player)
	for i, target in pairs(players) do
		j, i = map_to_pixel(target["pos_x"], target["pos_y"])
		j2, i2 = map_to_pixel(player["pos_x"], player["pos_y"])
		if (target["name"] ~= player["name"] and
			math.sqrt(math.pow(j - j2, 2) + math.pow(i - i2, 2)) < tile_sizey) then
			target["life"] = target["life"] - 10
			target["no_hit"] = 120
			cut_sound:play()
		end
	end
	player["cut_state"] = 60
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

function get_fire(value)
	tmp_posx = (value["pos_x"] - 1) * tile_sizex
	tmp_posy = (value["pos_y"] - 1) * tile_sizey
	vec_x, vec_y = get_view_vector(value)
	repeat
		for i, player in pairs(players) do
			if ((value["name"] ~= player["name"]) and math.pow(tmp_posx - (player["pos_x"] - 1) * tile_sizex, 2)
				+ math.pow(tmp_posy - (player["pos_y"] - 1) * tile_sizey, 2) < math.pow(tile_sizey / 2, 2)) then
				if (check_shield(player, vec_x, vec_y) == 1) then
					player["shield_life"] = player["shield_life"] - 1
					if (player["shield_life"] > 0) then
						shield_sound:play()
					else
						shield_break_sound:play()
					end
					table.insert(impact, {pos_x = tmp_posx, pos_y = tmp_posy, frame = 15, sprite = sprite_impact})
					return player, 1					
				elseif (player["no_hit"] and player["no_hit"] == 0) then
					table.insert(impact, {pos_x = (player["pos_x"] - 1) * tile_sizex, pos_y = (player["pos_y"] - 1) * tile_sizey, frame = 15, sprite = sprite_skull, color = player.color})
				end
				return player, 0
			end
		end
		if (blocks[map[math.floor(tmp_posy / tile_sizey) + 1][math.floor(tmp_posx / tile_sizex) + 1]]["crossable"] == 0) then
			blocks[map[math.floor(tmp_posy / tile_sizey) + 1][math.floor(tmp_posx / tile_sizex) + 1]]["shooted_on"](math.floor(tmp_posx / tile_sizex) + 1,  math.floor(tmp_posy / tile_sizey) + 1, player)
			table.insert(impact, {pos_x = tmp_posx, pos_y = tmp_posy, frame = 15, sprite = sprite_impact, color = value.color})
			break
		end
		tmp_posx = tmp_posx + vec_x
		tmp_posy = tmp_posy + vec_y
	until (tmp_posx < 0 or tmp_posx > screen_w or
	tmp_posy < 0 or tmp_posy > screen_h)
	return nil, 0
end