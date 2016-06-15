function draw_impact(impact, sprite_impact)
	for i, value in pairs(impact) do
		if (value.color) then
			love.graphics.setColor(value.color[1], value.color[2], value.color[3], 255)
		else
			love.graphics.setColor(255, 255, 255, 255)
		end
		love.graphics.draw(impact[i]["sprite"], impact[i]["pos_x"] - impact[i]["sprite"]:getWidth() / 2, impact[i]["pos_y"] - impact[i]["sprite"]:getHeight() / 2)
		impact[i]["frame"] = impact[i]["frame"] - 1
		if (impact[i]["frame"] <= 0) then
			table.remove(impact, i)
		end
	end
end

function draw_victory()
	if game_ended() == 1 then
		if (game_victory == 0) then
			win_sound:play()
			game_victory = 1
			alive_players = get_alive_players()
		end
		if (alive_players[1]) then
			love.graphics.setColor(alive_players[1]["color"][1], alive_players[1]["color"][2], alive_players[1]["color"][3], 255)
			love.graphics.draw(win_screen, screen_w / 2 - win_screen:getWidth() / 2, screen_h / 2 - win_screen:getHeight() / 2, 0, 1, 1)
			love.graphics.setColor(255, 255, 255, 255)
			table.insert(impact, {pos_x = math.random(screen_w), pos_y = math.random(screen_h), frame = 15, sprite = fireworks[math.random(4)]})
	 	end
	end
end

function draw_flames()
	if (fire_blocks) then
		for i, block in pairs(fire_blocks) do
			love.graphics.draw(fire_sprite[math.floor(fire_blocks[i]["state"] / 7) % 6 + 1], ((fire_blocks[i]["x"] - 1) * tile_sizex),
			((fire_blocks[i]["y"] - 1) * tile_sizey), 0,
			blocks.fire["scale_x"],
			blocks.fire["scale_y"])
		end	
	end
end		

function draw_electricity()
	if (electric_blocks) then
		for i, block in pairs(electric_blocks) do
			love.graphics.draw(electric_sprite[math.floor(electric_blocks[i]["state"] / 7) % 6 + 1], ((electric_blocks[i]["x"] - 1) * tile_sizex),
				((electric_blocks[i]["y"] - 1) * tile_sizey), 0,
				blocks.bolt_ball["scale_x"],
				blocks.bolt_ball["scale_y"])
		end	
	end
end		

function draw_block(block, pos_x, pos_y)
	love.graphics.draw(block["sprite"], ((pos_x - 1) * tile_sizex), ((pos_y - 1) * tile_sizey), 0, block["scale_x"], block["scale_y"])
end

function draw_powerups()
	for i, powerup in pairs(powerups) do
		draw_block(powerup.block, powerup.x, powerup.y)
	end
end

function draw_map()
	for i = 1, x_fields, 1 do
		for j = 1, y_fields, 1 do
			if (map[j][i].type ~= "fire") then
				draw_block(map[j][i], i, j)
			end
		end
	end
	draw_flames()
	draw_electricity()
	draw_powerups()
end

nameplate_h = 10
nameplate_w = tile_sizex
nameplate_space_y = 10
nameplate_space_x = 4

function draw_player_life(player)
	nameplate_w = tile_sizex
	if (player["life"] > 80) then love.graphics.setColor(0, 200, 0, 255)
	elseif (player["life"] > 60) then love.graphics.setColor(200, 200, 0, 255)
	elseif (player["life"] > 40) then love.graphics.setColor(100, 100, 0, 255)
	elseif (player["life"] > 20) then love.graphics.setColor(150, 75, 0, 255)
	else love.graphics.setColor(255, 0, 0, 255)
	end
	local pos_x = (player["pos_x"] - 1) * tile_sizex - tile_sizex / 2
	local pos_y = (player["pos_y"] - 1) * tile_sizey - tile_sizey / 2 - nameplate_space_y - nameplate_h
	for i = 1, player["life"] / 20, 1 do
		love.graphics.rectangle("fill", pos_x, pos_y, (nameplate_w - nameplate_space_x * 4) / 5, nameplate_h)	
		pos_x = pos_x + (nameplate_w - nameplate_space_x * 4) / 5 + nameplate_space_x 
	end
	love.graphics.rectangle("fill", pos_x, pos_y, ((nameplate_w - nameplate_space_x * 4) / 5) * ((player["life"] % 20) / 20), nameplate_h)	
	love.graphics.setColor(255, 255, 255, 255)
end

function draw_players(players, walk)
	local new_r = 0
	for i, player in pairs(players) do
		if (player["alive"] == 1) then
			if (player["cut_state"] > 50) then
	 			new_r = player["r"] + math.pi * 2 * ((player["cut_state"] - 50) / 10)
 			else
 				draw_fire(player)
 	 			new_r = player["r"]
 			end
 			new_r = new_r % (math.pi * 2)
			tmp_x, tmp_y = map_to_pixel(player["pos_x"], player["pos_y"])
			tmp_x, tmp_y = rotate_pos(tmp_x, tmp_y, new_r, walk)		
				love.graphics.setColor(player["color"][1], player["color"][2], player["color"][3], 255)
			if (math.floor(player["no_hit"] / 10) % 3 ~= 1) then
				love.graphics.draw(walk[math.floor(player["frame"])], tmp_x, tmp_y, new_r, player["scale_x"], player["scale_y"])
			end
			draw_player_life(player)
		end
	end
end

function draw_game()
	draw_map()
	draw_impact(impact, sprite_impact)
	draw_players(players, walk)
	draw_victory()
end