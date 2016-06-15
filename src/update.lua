function move_player(value, i)
	local done = 0
	local x = joysticks[i]:getGamepadAxis("leftx")
	local y = joysticks[i]:getGamepadAxis("lefty")
	local new_x = math.floor(value["pos_x"] + x * value["speed"])
	local new_y = math.floor(value["pos_y"] + y * value["speed"])
	if (math.abs(x) > 0.2 or math.abs(y) > 0.2) then
		if (new_y <= y_fields and new_y >= 1) then
			if (map[new_y][math.floor(value["pos_x"])]["walkable"] == 1) then
				value["pos_y"] = value["pos_y"] + y * value["speed"]
				done = 1
			end
		end
		if (new_x <= x_fields and new_x >= 1) then
			if (map[math.floor(value["pos_y"])][new_x]["walkable"] == 1) then
				value["pos_x"] = value["pos_x"] + x * value["speed"]
			end
		end
		if done then
			value["frame"] = value["frame"] + (1 / 4)
			if value["frame"] > 4.0 then value["frame"] = 1 end
		end
	end
	map[math.floor(value["pos_y"])][math.floor(value["pos_x"])]["walked_on"] (math.floor(value["pos_x"]), math.floor(value["pos_y"]), value)
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
			print(px, py)
    		if (math.random(2) == 1) then
				table.insert(powerups, {x = px, y = py, block = powerup_life_block})
			else
				table.insert(powerups, {x = px, y = py, block = powerup_shield_block})
			end
			item_spawn_sound:play()
			done = 1
		end
		done = done + 1
	until (done > 0)
end

item_spawn = item_spawn_rate

function update_item_spawn(dt)
	item_spawn = item_spawn - dt
	if (item_spawn <= 0) then
		item_spawn = item_spawn_rate
        spawn_item()		
	end
end

function shoot(player)
	local have_shield = 0
    target, have_shield = get_fire(player)
    player["ammo"] = player["ammo"] - 1
	if (target and have_shield == 0 and target["no_hit"] <= 0) then
		laser2:play()
		target["life"] = target["life"] - 20
		target["no_hit"] = 2
	else
		laser:play()
	end
	player["shoot"] = 1
end

function update_weapon_player(value, i)
	if (math.abs(joysticks[i]:getGamepadAxis("righty")) > 0.4 or math.abs(joysticks[i]:getGamepadAxis("rightx")) > 0.4) then
		value["r"] = math.atan2(joysticks[i]:getGamepadAxis("righty"), joysticks[i]:getGamepadAxis("rightx")) + math.pi / 2
	end
	if (value["ammo"] > 0  and value["shield"] == 0 and joysticks[i]:getGamepadAxis("triggerright") > 0.8 and value["shoot"] == 0 and value["cooldown"] <= 0) then
           shoot(value)
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

function update_powerup_player(player)
	for i, powerup in pairs(powerups) do
		if (math.floor(player.pos_x) == powerup.x and math.floor(player.pos_y) == powerup.y) then
			powerup.block.walked_on(powerup.x, powerup.y, player)
			table.remove(powerups, i)
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
	move_player(value, i)
	update_weapon_player(value, i)
	update_powerup_player(value, i)
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

total_time = 0
function update_game(dt)
	frame_speed = default_speed / (love.timer.getFPS() / 60)
	update_players(dt)
	total_time = 0
	update_element(fire_blocks, dt)
	update_element(electric_blocks, dt)
	update_item_spawn(dt)
	if (love.keyboard.isDown("space")) then
		restart()
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