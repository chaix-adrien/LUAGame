function move_player(value, i)
	if (math.abs(joysticks[i]:getGamepadAxis("righty")) > 0.4 or math.abs(joysticks[i]:getGamepadAxis("rightx")) > 0.4) then
		value["r"] = math.atan2(joysticks[i]:getGamepadAxis("righty"), joysticks[i]:getGamepadAxis("rightx")) + math.pi / 2
	end
	local done = 0
	local x = joysticks[i]:getGamepadAxis("leftx")
	local y = joysticks[i]:getGamepadAxis("lefty")
	local new_x = math.floor(value["pos_x"] + x * value["speed"])
	local new_y = math.floor(value["pos_y"] + y * value["speed"])
	if (math.abs(x) > 0.2 or math.abs(y) > 0.2) then
		if (new_y <= y_fields and new_y >= 1) then
			if (blocks[map[new_y][math.floor(value["pos_x"])]]["walkable"] == 1) then
				value["pos_y"] = value["pos_y"] + y * value["speed"]
				done = 1
			end
		end
		if (new_x <= x_fields and new_x >= 1) then
			if (blocks[map[math.floor(value["pos_y"])][new_x]]["walkable"] == 1) then
				value["pos_x"] = value["pos_x"] + x * value["speed"]
			end
		end
		if done then
			value["frame"] = value["frame"] + (1 / 4)
			if value["frame"] > 4.0 then value["frame"] = 1 end
		end
	end
	blocks[map[math.floor(value["pos_y"])]  [math.floor(value["pos_x"])]  ] ["walked_on"] (math.floor(value["pos_x"]), math.floor(value["pos_y"]), value)
end

function update_element(element_blocks)
	if fire_blocks then
		for i, block in pairs(element_blocks) do
			block["state"] = block["state"] - 1
			if (block["state"] <= 0) then
				map[element_blocks[i]["y"]][element_blocks[i]["x"]] = 1
				table.remove(element_blocks, i)
			end
		end
	end
end

function spawn_item()
    local done = -100 -- a voir
    repeat
		x = math.random(x_fields - 1) + 1
		y = math.random(y_fields - 1) + 1
	    if (map[y][x] == 1) then
    		if (math.random(2) == 1) then
				map[y][x] = 11
			else
    			map[y][x] = 12
			end
			item_spawn_sound:play()
			done = 1
		end
		done = done + 1
	until (done > 0)
end

function update_item_spawn()
	item_spawn = item_spawn - 1
	if (item_spawn <= 0) then
		item_spawn = 900
        spawn_item()		
	end
end

function shoot(player)
	local have_shield = 0
    target, have_shield = get_fire(player)
    player["ammo"] = player["ammo"] - 1
	if (target and have_shield == 0 and target["no_hit"] == 0) then
		laser2:play()
		target["life"] = target["life"] - 20
		target["no_hit"] = 120
	else
		laser:play()
	end
	player["shoot"] = 1
end

function update_player(value, i)
	if (value["cut_state"] > 0) then
		value["cut_state"] = value["cut_state"] - 1
	end
	if (value["cooldown"] > 0) then
		value["cooldown"] = value["cooldown"] - 1
	end
	if (value["no_hit"] > 0) then
		value["no_hit"] = value["no_hit"] - 1
	end
	if (auto_reload == 1 and value["ammo"] == 0) then
		reload(value, reload_sound)
	end
	if (i and value["life"] <= 0) then
        value.alive = 0    
	end
end

function update_players()
	for i, value in pairs(players) do
	if (value.alive == 1) then
		move_player(value, i)
		if (value["ammo"] > 0  and value["shield"] == 0 and joysticks[i]:getGamepadAxis("triggerright") > 0.5 and value["shoot"] == 0 and value["cooldown"] == 0) then
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
		if (joysticks[i]:isGamepadDown("b") and value["shoot"] == 0 and value["cut_state"] == 0 and value["shield"] == 0) then
			cut_attack(value)
		end
		update_player(value, i)
		end
	end
	if (love.keyboard.isDown("space")) then
		restart()
	end
	if (love.keyboard.isDown("escape")) then
		os.exit()
	end
end

function update_music()
  	 if (not music) then
 	  	music = load_sound("music/music" .. tostring(math.random(4)) .. ".mp3", 0.7)
  	end
end

function love.update(dt)
    act_time = os.clock()
	update_players()
	update_element(fire_blocks)
	update_element(electric_blocks)
	update_item_spawn()
    update_music()
	last_time = act_time
end