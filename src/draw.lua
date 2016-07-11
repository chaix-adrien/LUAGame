function draw_impact(impact, sprite_impact, focus)
	for i, value in pairs(impact) do
		if (value.color) then
			love.graphics.setColor(value.color[1], value.color[2], value.color[3], 255)
		else
			love.graphics.setColor(255, 255, 255, 255)
		end
		x, y = map_to_pix(impact[i].pos_x, impact[i].pos_y, focus)
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

function draw_block(block, pos_x, pos_y, focus)
	scalex, scaley = get_sprite_scale(block.sprite[math.floor(block.frame)], focus) -- calculer dans draw_map et envoyer pour perf
	px, py = map_to_pixel(pos_x, pos_y, focus)
	love.graphics.draw(block.sprite[math.floor(block.frame)], px, py, 0, scalex, scaley)
end

function draw_powerup(powerup, x, y, focus)
		local sx = powerup.block.scale_x - (0.1 * powerup.block.scale_x *  math.abs(math.cos(powerup.state)))
		local sy = powerup.block.scale_y - (0.1 * powerup.block.scale_y * math.abs(math.cos(powerup.state)))
		local px = powerup.x + 0.4 - sx / 1.5
		local py = powerup.y + 0.4 - sy / 1.5
		px, py = map_to_pix(px, py, focus)
		love.graphics.draw(powerup.block.sprite, px, py,
		0, sx, sy)
end

function draw_powerups(focus)
	for i, powerup in pairs(powerups) do
		draw_powerup(powerup, powerup.x, powerup.y, focus)
	end
end

function get_to_draw_map_pos(x, y, focus)
	if (not focus) then
		return x, y
	end
	if (focus and focus.cam_view) then
		local wiew = focus.cam_view
	else
		local wiew = view
	end
	local retx = (focus.pos_x - wiew.w / 2) + (x - 1)
	local rety = (focus.pos_y - wiew.h / 2) + (y - 1)
	if (focus.pos_x >= focus.x_fields - wiew.w / 2 + 1) then retx = focus.x_fields - wiew.w + x end
	if (focus.pos_y >= focus.y_fields - wiew.h / 2 + 1) then rety = focus.y_fields - wiew.h + y end
	if (focus.pos_x <= wiew.w / 2 + 1) then retx = x end
	if (focus.pos_y <= wiew.h / 2 + 1) then rety = y end
	if (retx >= focus.x_fields + 1 or retx < 1) then retx = 1	end
	if (rety >= focus.y_fields + 1 or rety < 1) then rety = 1 end
	return retx, rety
end

function map_to_ori(x, y, focus)
	if not focus then
		return x, y
	end
	if (focus and focus.cam_view) then
		wiew = focus.cam_view
	else
		wiew = view
	end
	local retx = x - focus.pos_x + wiew.w / 2 + 1
	local rety = y - focus.pos_y + wiew.h / 2 + 1
	if (focus.pos_x >= focus.x_fields - wiew.w / 2 + 1) then retx = wiew.w + (x - focus.x_fields) end
	if (focus.pos_y >= focus.y_fields - wiew.h / 2 + 1) then rety = wiew.h + (y - focus.y_fields) end
	if (focus.pos_x <= wiew.w / 2 + 1) then retx = x end
	if (focus.pos_y <= wiew.h / 2 + 1) then rety = y end
	return retx, rety
end


function map_to_pix(x, y, focus)
	retx, rety = map_to_ori(x, y, focus)
	retx, rety = map_to_pixel(retx, rety, focus)
	return retx, rety
end

function draw_map(map, focus, powerup, players, mobs)
	if (focus) then
		focus["x_fields"] = table.getn(map[1])
		focus["y_fields"] = table.getn(map)
		if (focus.cam_view) then
			lim = focus.cam_view -- peut etre + 1
		else
			lim = view
		end
	else
		focus = {x_fields = table.getn(map), y_fields = table.getn(map[1])}
		lim = {w = x_fields - 1, h = y_fields - 1}
	end
	for i = 1, lim.w + 1, 1 do
		for j = 1, lim.h + 1, 1 do
			x, y = get_to_draw_map_pos(i, j, focus)
			if (i >= 1 and j >= 1 and i <= focus.x_fields and j <= focus.y_fields) then
				draw_block(map[math.floor(y)][math.floor(x)], i - (x % 1), j - (y % 1), focus)
			end
		end
	end
	draw_powerups(powerup, focus) -- TODO param des powerup a draw
	draw_players(players, walk, focus) -- TODO param des players a draw
	draw_mobs(mobs, focus) -- TODO param des mobs a draw
end

nameplate_h = 10
nameplate_w = tile_sizex
nameplate_space_y = 10
nameplate_space_x = 4

function get_focus_result(focus)
	if ((not tile_sizex or not tile_sizey) and not focus) then
		tile_size = {x = 0, y = 0}
	end
	if (focus and focus.cam_view) then
		wiew = focus.cam_view
	else
		wiew = view
	end
	if (focus and focus.cam_size) then
		screen = focus.cam_size
	else
		screen = {w = screen_w, h = screen_h}
	end
	local size = {w = screen.w / wiew.w, h = screen.h / wiew.h}
	size.w = smaller(size)
	size.h = size.w
	return tile_size, view, screen, size
end

function draw_player_life(player, focus)
	tile_size, wiew, screen, size = get_focus_result(focus)
	nameplate_w = size.w
	if (player["life"] > 80) then love.graphics.setColor(0, 200, 0, 255)
	elseif (player["life"] > 60) then love.graphics.setColor(200, 200, 0, 255)
	elseif (player["life"] > 40) then love.graphics.setColor(100, 100, 0, 255)
	elseif (player["life"] > 20) then love.graphics.setColor(150, 75, 0, 255)
	else love.graphics.setColor(255, 0, 0, 255)
	end
	pos_x, pos_y = map_to_pix(player.pos_x, player.pos_y, focus)
	pos_x = pos_x - size.w / 2
	pos_y = pos_y - size.h / 2 - nameplate_space_y - nameplate_h
	for i = 1, player["life"] / 20, 1 do
		love.graphics.rectangle("fill", pos_x, pos_y, (nameplate_w - nameplate_space_x * 4) / 5, nameplate_h)	
		pos_x = pos_x + (nameplate_w - nameplate_space_x * 4) / 5 + nameplate_space_x 
	end
	love.graphics.rectangle("fill", pos_x, pos_y, ((nameplate_w - nameplate_space_x * 4) / 5) * ((player["life"] % 20) / 20), nameplate_h)	
	love.graphics.setColor(255, 255, 255, 255)
end

function draw_players(players, walk, focus)
	local new_r = 0
	for i, player in pairs(players) do	
		if (player["alive"] == 1) then
			if (player["cut_state"] > 50 / 60) then
	 			new_r = player["r"] + math.pi * 2 * ((player["cut_state"] - 50 / 60) / 0.1)
 			else
 				draw_fire(player, focus)
 	 			new_r = player["r"]
 			end
 			new_r = new_r % (math.pi * 2)
			tmp_x, tmp_y = map_to_pix(player.pos_x, player.pos_y, focus)
			tmp_x, tmp_y = rotate_pos(tmp_x, tmp_y, new_r, walk, focus)		
			player.scale_x, player.scale_y = get_sprite_scale(walk[1], focus)
			love.graphics.setColor(player["color"][1], player["color"][2], player["color"][3], 255)						
			if (math.floor(player["no_hit"] * 10) % 3 ~= 1) then
				love.graphics.draw(walk[math.floor(player["frame"])], tmp_x, tmp_y, new_r, player["scale_x"], player["scale_y"])
			end
			draw_player_life(player, focus)
		end
	end
end

function draw_mobs(focus)
	for i, mob_type in pairs(mobs) do
		for j, mob in pairs(mob_type) do
			mob.draw(mob, focus)
		end
	end
end

function draw_editor()
	draw_map(map, cam)	
	cam_scroller.cam_pos_pix.x = 0	
	draw_map(block_selec_r, cam_scroller)
	cam_scroller.cam_pos_pix.x = screen_w - cam_scroller.cam_size.w
	draw_map(block_selec_l, cam_scroller)
end

function draw_game()
	draw_map(map, players[1])
	draw_impact(impact, sprite_impact, players[1])
	draw_victory()
end

-- TODO URGENT:
--tester changer view
--tester sans focus
--
--
--
--