function draw_impact(impact, sprite_impact)
	for i, value in pairs(impact) do
		if (value.color) then
			love.graphics.setColor(value.color[1], value.color[2], value.color[3], 255)
		else
			love.graphics.setColor(255, 255, 255, 255)
		end
		x, y = map_to_pix(impact[i].pos_x, impact[i].pos_y)
		love.graphics.draw(impact[i]["sprite"], x - impact[i]["sprite"]:getWidth() / 2, y - impact[i]["sprite"]:getHeight() / 2)
		impact[i]["frame"] = impact[i]["frame"] - 1
		if (impact[i]["frame"] <= 0) then
			table.remove(impact, i)
		end
	end
	love.graphics.setColor(255, 255, 255, 255)
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
			table.insert(impact, {pos_x = math.random(x_fields), pos_y = math.random(y_fields), frame = 15, sprite = fireworks[math.random(4)]})
	 	end
	end
end

function draw_block(block, pos_x, pos_y)
	love.graphics.draw(block.sprite[math.floor(block.frame)], ((pos_x - 1) * tile_sizex), ((pos_y - 1) * tile_sizey), 0, block["scale_x"], block["scale_y"])
end

function draw_powerup(powerup, x, y)
		local sx = powerup.block.scale_x - (0.1 * powerup.block.scale_x *  math.abs(math.cos(powerup.state)))
		local sy = powerup.block.scale_y - (0.1 * powerup.block.scale_y * math.abs(math.cos(powerup.state)))
		px, py = map_to_pix(powerup.x, powerup.y)
		local px = px + (powerup.block.scale_x - sx) * tile_sizex / 2
		local py = py + (powerup.block.scale_y - sy) * tile_sizey / 2
		love.graphics.draw(powerup.block.sprite, px, py,
		0, sx, sy)
end

function draw_powerups()
	for i, powerup in pairs(powerups) do
		draw_powerup(powerup, powerup.x, powerup.y)
	end
end

function get_to_draw_map_pos(x, y, player)
	if (not player) then
		player = players[1]
	end
	local retx = (player.pos_x - view.w / 2) + (x - 1)
	local rety = (player.pos_y - view.h / 2) + (y - 1)
	if (player.pos_x >= x_fields - view.w / 2 + 1) then retx = x_fields - view.w + x end
	if (player.pos_y >= y_fields - view.h / 2 + 1) then rety = y_fields - view.h + y end
	if (player.pos_x <= view.w / 2 + 1) then retx = x end
	if (player.pos_y <= view.h / 2 + 1) then rety = y end
	if (retx >= x_fields + 1 or retx < 1) then retx = 1	end
	if (rety >= y_fields + 1 or rety < 1) then rety = 1 end
	return retx, rety
end

function map_to_pix(x, y, player)
	if (not player) then
		player = players[1]
	end
	local retx = x - player.pos_x + view.w / 2 + 1
	local rety = y - player.pos_y + view.h / 2 + 1
	if (player.pos_x >= x_fields - view.w / 2 + 1) then retx = view.w + (x - x_fields) end
	if (player.pos_y >= y_fields - view.h / 2 + 1) then rety = view.h + (y - y_fields) end
	if (player.pos_x <= view.w / 2 + 1) then retx = x end
	if (player.pos_y <= view.h / 2 + 1) then rety = y end
	retx, rety = map_to_pixel(retx, rety)
	return retx, rety
end

function draw_map()
	for i = 1, view.w + 1, 1 do
		for j = 1, view.h + 1, 1 do
			x, y = get_to_draw_map_pos(i, j)
			draw_block(map[math.floor(y)][math.floor(x)], i - (x % 1), j - (y % 1 ))
		end
	end
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
	pos_x, pos_y = map_to_pix(player.pos_x, player.pos_y)
	pos_x = pos_x - tile_sizex / 2
	pos_y = pos_y - tile_sizey / 2 - nameplate_space_y - nameplate_h
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
			if (player["cut_state"] > 50 / 60) then
	 			new_r = player["r"] + math.pi * 2 * ((player["cut_state"] - 50 / 60) / 0.1)
 			else
 				draw_fire(player)
 	 			new_r = player["r"]
 			end
 			new_r = new_r % (math.pi * 2)
			tmp_x, tmp_y = map_to_pix(player.pos_x, player.pos_y)
			tmp_x, tmp_y = rotate_pos(tmp_x, tmp_y, new_r, walk)		
				love.graphics.setColor(player["color"][1], player["color"][2], player["color"][3], 255)						
			if (math.floor(player["no_hit"] * 10) % 3 ~= 1) then
				love.graphics.draw(walk[math.floor(player["frame"])], tmp_x, tmp_y, new_r, player["scale_x"], player["scale_y"])
			end
			draw_player_life(player)
		end
	end
end

function draw_mobs()
	for i, mob_type in pairs(mobs) do
		for j, mob in pairs(mob_type) do
			mob.draw(mob, i, j)
		end
	end
end

function draw_game()
	draw_map()
	draw_impact(impact, sprite_impact)
	draw_mobs()
	draw_victory()
	draw_players(players, walk)
end