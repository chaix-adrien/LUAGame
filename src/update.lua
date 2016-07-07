
function move_of(p, v, i, fly)
	local n = math.sqrt(math.pow(v.x, 2) + math.pow(v.y, 2))
	local nv = {x = (v.x / n) * i, y = (v.y / n) * i}
	local np = {x = p.x + nv.x, y = p.y + nv.y}
	local out = {x = p.x, y = p.y}
	if ((np.y >= 1 and np.y <= y_fields + 1) and (fly == 1 or map[math.floor(np.y)][math.floor(p.x)].walkable == 1)) then
		out.y = np.y
	end
	if ((np.x >= 1 and np.x <= x_fields + 1) and (fly == 1 or map[math.floor(out.y)][math.floor(np.x)].walkable == 1)) then
		out.x = np.x
	end
	return out.x, out.y
end

function walked_on_mobs(player)
	for i, mob_type in pairs(mobs) do
		for j, mob in pairs(mob_type) do
			if (is_on_mob(player.pos_x, player.pos_y, mob) == 1) then
				mob.walked_on(player, mob, i, j)
			end
		end
	end
end

function move_player(value, i, dt)
	local done = 0
	local x = joysticks[i]:getGamepadAxis("leftx")
	local y = joysticks[i]:getGamepadAxis("lefty")
	if (math.abs(x) > 0.2 or math.abs(y) > 0.2) then
		value.pos_x, value.pos_y = move_of({x = value.pos_x, y = value.pos_y}, {x = x, y = y}, value.speed)		
		value["frame"] = value["frame"] + (1 / 4)
		if value["frame"] > 4.0 then value["frame"] = 1 end
	end
	map[math.floor(value["pos_y"])][math.floor(value["pos_x"])]["walked_on"] (math.floor(value["pos_x"]), math.floor(value["pos_y"]), value)
	walked_on_mobs(value)
	walked_on_powerup(value)
end

function update_element(element_blocks, dt)
	if fire_blocks then
		for i, block in pairs(element_blocks) do
			block["state"] = block["state"] - dt
			if (block["state"] <= 0) then
				map[element_blocks[i]["y"]][element_blocks[i]["x"]] = blocks.floor
				table.remove(element_blocks, i)
			end
		end
	end
end

function spawn_item()
    local done = -100 -- a voir
    repeat
		px = math.random(x_fields - 1) + 1
		py = math.random(y_fields - 1) + 1
	    if (map[py][px].walkable == 1) then
    		if (math.random(2) == 1) then
				table.insert(powerups, {x = px, y = py, state = 0, block = powerup_life_block})
			else
				table.insert(powerups, {x = px, y = py, state = 0, block = powerup_shield_block})
			end
			item_spawn_sound:play()
			done = 1
		end
		done = done + 1
	until (done > 0)
end

item_spawn = item_spawn_rate

function update_item(dt)
	item_spawn = item_spawn - dt
	if (item_spawn <= 0) then
		item_spawn = item_spawn_rate
        spawn_item()		
	end
	for i, item in pairs(powerups) do
		item.state = item.state + dt
	end
end

function update_weapon_player(value, i)
	if (math.abs(joysticks[i]:getGamepadAxis("righty")) > 0.4 or math.abs(joysticks[i]:getGamepadAxis("rightx")) > 0.4) then
		value.r = vec_to_r(joysticks[i]:getGamepadAxis("rightx"), joysticks[i]:getGamepadAxis("righty"))
	end
	if (value["ammo"] > 0  and value["shield"] == 0 and joysticks[i]:getGamepadAxis("triggerright") > 0.8 and value["shoot"] == 0 and value["cooldown"] <= 0) then
           shoot({x = value.pos_x, y = value.pos_y}, value.r, 20, value)
	elseif (joysticks[i]:getGamepadAxis("triggerright") < 0.8 and value["shoot"] == 1) then
		value["shoot"] = 0
	end
	if (joysticks[i]:getGamepadAxis("triggerleft") > 0.8) then
		value["shield"] = 1
		value["speed"] = 0.065
	else
		value["shield"] = 0
		if (value["speed"] == 0.65) then
			value["speed"] = 0.1
		end
	end
	if (joysticks[i]:isGamepadDown("x") and value["shoot"] == 0) then
		reload(value, reload_sound)
	end
	if (joysticks[i]:isGamepadDown("b") and value["shoot"] == 0 and value["cut_state"] <= 0 and value["shield"] == 0) then
		cut_attack(value)
	end
	if (auto_reload == 1 and value["ammo"] == 0) then
		reload(value, reload_sound)
	end
end

function walked_on_powerup(player)
	for i, powerup in pairs(powerups) do
		if (math.floor(player.pos_x) == powerup.x and math.floor(player.pos_y) == powerup.y) then
			if (powerup.block.walked_on(powerup.x, powerup.y, player) == 1) then
				table.remove(powerups, i)
			end
		end
	end
end

function update_player(value, i, dt)
	if (value["cut_state"] > 0) then
		value["cut_state"] = value["cut_state"] - dt
	end
	if (value["cooldown"] > 0) then
		value["cooldown"] = value["cooldown"] - dt
	end
	if (value["no_hit"] > 0) then
		value["no_hit"] = value["no_hit"] - dt
	end
	move_player(value, i, dt)
	update_weapon_player(value, i)
	if (i and value["life"] <= 0) then
        value.alive = 0    
	end
end

function update_players(dt)
	for i, value in pairs(players) do
		if (value.alive == 1) then
			update_player(value, i, dt)
		end
	end
end

function update_map(dt)
	for x=1, x_fields, 1 do
		for y=1, y_fields, 1 do
			local block = map[y][x]
			if map[y][x].type == "fire" or map[y][x].type == "bolt_ball" then
				map[y][x].state = map[y][x].state - dt
				if (map[y][x].state < 0) then turn_block_to_floor(x, y) end
			end
			if (block.animated == 1) then
				block.frame = block.frame + 2 * frame_speed
				if (block.frame > #block.sprite) then
					block.frame = 1
				end
			end
		end
	end
end

function update_mob_target(mob)
	if (mob.target) then
		if (mob.target.alive == 0) then
			mob.target = players[math.random(#players)]
		end
	end
end

function update_mobs(dt)
	for i, mob_type in pairs(mobs) do
		for j, mob in pairs(mob_type) do
			update_mob_target(mob)
			mob.update(mob, dt)
			mob.move(mob, dt)
			if (mob.life <= 0) then
				table.remove(mobs[i], j)
			end
		end
	end
end

function udpate_editor(dt)
end

total_time = 0
function update_game(dt)
	if (love.timer.getFPS() > 10) then
		frame_speed = default_speed / (love.timer.getFPS() / 60)
	else
		frame_speed = 0.01
	end
	if (math.abs(frame_speed) < 0.01) then
		frame_speed = 0.01
	end
	update_map(dt)
	update_mobs(dt)
	update_players(dt)
	total_time = 0
	update_element(fire_blocks, dt)
	update_element(electric_blocks, dt)
	update_item(dt)
	if (love.keyboard.isDown("space")) then
		restart_pvp()
	end
	if (love.keyboard.isDown('k')) then
		players[1].alive = 0
		table.remove(players, 1)
		for i=0, 1000000000, 1 do tmp = i / 4 end
	end
	if (love.keyboard.isDown("escape")) then
		if (launch_on_menu == 1) then
			for i=0, 1000000000, 1 do tmp = i / 4 end
			go_to_main_menu()
		else
			os.exit()
		end
	end
end