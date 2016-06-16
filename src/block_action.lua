--
--
--  SHOOTED ON --
--
--

function shooted_on_nothing(x, y, player)
	return 0
end

function shoot_on_brick(x, y, player)
	print("brick", map[y][x].type, map[y][x].state, blocks.brick.state)
	if (map[y][x].type == "brick" and map[y][x].state == 0) then
		map[y][x].state = 1
		map[y][x].frame = 2
	elseif (map[y][x].type == "brick" and map[y][x].state == 1) then
		turn_block_to_floor(x, y)
	end
	return (1)
end 

function break_box(x, y, player)
	box_sound:play()
	turn_block_to_fire(x, y, player)
	return (1)
end

function explode(x, y, player)
	tnt_sound:play()
	for i = y - 1, y + 1, 1 do
		for j = x - 1, x + 1, 1 do
			if (i > 0 and i < y_fields and j > 0 and j < x_fields) then
				if (math.random(2) ~= 1 and not (i == y and j == x)) then
					turn_block_to_fire(j, i, player)
				end
				for p, player in pairs(players) do
					if (math.floor(player["pos_x"]) == j and math.floor(player["pos_y"]) == i) then
						player["life"] = player["life"] - 40
						player["no_hit"] = 2
					end
				end
			end
		end
	end
	map[y][x] = copy_table(blocks.hole)
	return (1)
end

function electric_explode(x, y, player)
	electric_explode_sound:play()
	for i = y - 1, 1, -1 do
		if (map[i][x].type == "floor") then
			turn_block_to_electric(x, i, player)
		else
			break
		end
	end
	for i = y + 1, y_fields, 1 do
		if (map[i][x].type == "floor") then
			turn_block_to_electric(x, i, player)
		else
			break
		end
	end
	for i = x - 1, 1, -1 do
		if (map[y][i].type == "floor") then
			turn_block_to_electric(i, y, player)
		else
			break
		end
	end
	for i = x + 1, x_fields, 1 do
		if (map[y][i].type == "floor") then
			turn_block_to_electric(i, y, player)
		else
			break
		end
	end
	turn_block_to_electric(x, y, player)
	return (1)
end

--
--
--  WALKED ON --
--
--

function reset_status(x, y, player)
	player["speed"] = frame_speed
end

function fire_damage(x, y, player)
	if (player["no_hit"] <= 0) then
		player["life"] = player["life"] - 10
		player["no_hit"] = 1
	end
end

function electric_damage(x, y, player)
	if (player["shield_life"] > 0) then
		player["shield_life"] = 0
		shield_break_sound:play()
	end
end

function mud(x, y, player)
	player["speed"] = default_speed / 3
end

function waterbomb(x, y, player)
	for i = y - 1, y + 1, 1 do
		for j = x - 1, x + 1, 1 do
			if (((i > 0 and i < y_fields and j > 0 and j < x_fields and map[i][j].type == "floor") and math.random(3) == 2) or (i == y and j == x)) then
				waterbomb_sound:play()
				map[i][j] = copy_table(blocks.mud)
			end
		end
	end
end

function powerup_life(x, y, player)
	if (player["life"] ~= 100) then
		powerup_life_sound:play() --TODO Laiser owerup si innutile
	end
	player["life"] = (player["life"] + 40)
	if (player["life"] > 100) then
		player["life"] = 100
	end
end

function powerup_shield(x, y, player)
	if (player["shield_life"] < 3) then
		powerup_shield_sound:play()
		player["shield_life"] = 3
	end
end

function powerup_invincible(x, y, player)
	player["no_hit"] = 2
end

function powerup_ammo(x, y, player)
	player["ammo"] = 10
end

--
--
-- CUT ON --
--
--

function cut_on_nothing(x, y, player)
	return nil
end

function open_chest(px, py, player)
	if (math.random(2) == 2) then
		table.insert(powerups, {x = px, y = py, block = powerup_invincible_block})
	else
		table.insert(powerups, {x = px, y = py, block = powerup_ammo_block})
	end
	turn_block_to_floor(px, py)
end


--
--
--  MISC --
--
--

function turn_block_to_fire(px, py, player)
	if (map[py][px].type ~= "mud") then
		map[py][px] = copy_table(blocks.fire)
	end
	return (1)
end

function turn_block_to_electric(px, py, player)
	if (map[py][px].type ~= "mud") then
		map[py][px] = copy_table(blocks.bolt_ball)
	end
	return (1)
end

function turn_block_to_floor(x, y)
	map[y][x] = copy_table(blocks.floor)
	return (1)
end
