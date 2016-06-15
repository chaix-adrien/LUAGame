--
--
--  SHOOTED ON --
--
--

function shooted_on_nothing(x, y, player)
	return nil
end

function shoot_on_brick(x, y, player)
	if (map[y][x].type == "brick") then
		map[y][x] = blocks.brocken_brick
	elseif (map[y][x].type == "brocken_brick") then
		map[y][x] = blocks.floor
	end
end 

function break_box(x, y, player)
	box_sound:play()
	turn_block_to_fire(x, y, player)
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
						player["no_hit"] = 120
					end
				end
			end
		end
	end
	map[y][x] = blocks.hole
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
end

--
--
--  WALKED ON --
--
--

function reset_status(x, y, player)
	player["speed"] = 0.1
end

function fire_damage(x, y, player)
	if (player["no_hit"] == 0) then
		player["life"] = player["life"] - 10
		player["no_hit"] = 60
	end
end

function electric_damage(x, y, player)
	if (player["shield_life"] > 0) then
		player["shield_life"] = 0
		shield_break_sound:play()
	end
end

function mud(x, y, player)
	player["speed"] = 0.03
end

function waterbomb(x, y, player)
	for i = y - 1, y + 1, 1 do
		for j = x - 1, x + 1, 1 do
			if (((i > 0 and i < y_fields and j > 0 and j < x_fields and map[i][j].type == "floor") and math.random(3) == 2) or (i == y and j == x)) then
				waterbomb_sound:play()
				map[i][j] = blocks.mud
			end
		end
	end
end

function powerup_life(x, y, player)
	if (player["life"] ~= 100) then
		map[y][x] = blocks.floor 
		powerup_life_sound:play()
	end
	player["life"] = (player["life"] + 40)
	if (player["life"] > 100) then
		player["life"] = 100
	end
end

function powerup_shield(x, y, player)
	if (player["shield_life"] < 3) then
		map[y][x] = blocks.floor
		powerup_shield_sound:play()
		player["shield_life"] = 3
	end
end

function powerup_invincible(x, y, player)
	player["no_hit"] = 120
	turn_block_to_floor(x, y , player)
end

function powerup_ammo(x, y, player)
	player["ammo"] = 10
	turn_block_to_floor(x, y , player)
end

--
--
-- CUT ON --
--
--

function cut_on_nothing(x, y, player)
	return nil
end

function open_chest(x, y, player)
	if (math.random(2) == 2) then
		map[y][x] = blocks.floor
	else
	map[y][x] = blocks.floor
	end
end


--
--
--  MISC --
--
--

function turn_block_to_fire(px, py, player)
	if (map[py][px].type ~= "mud") then
		map[py][px] = blocks.fire
	end
	table.insert(fire_blocks, {x = px, y = py, state = fire_time})
end

function turn_block_to_electric(px, py, player)
	if (map[py][px].type ~= "mud") then
		map[py][px] = blocks.bolt_ball
	end
	table.insert(electric_blocks, {x = px, y = py, state = fire_time})
end

function turn_block_to_floor(x, y)
	map[y][x] = blocks.floor
end
