function create_player(player_name, img)
	local player = {
		name = player_name,
		alive = 1,
		pos_x = 0, pos_y = 0,
		move_x = 0,	move_y = 0, -- useless
		aim_x = 0,  aim_y = 0,
		r = 1,
		shield = 0, shield_life = 3,
		scale_x = tile_sizex / walk[1]:getWidth(),
		scale_y = tile_sizey / walk[1]:getHeight(),
		speed = frame_speed,
		life = 100,
		shoot = 0,
		ammo = 4,
		frame = 1,
		cooldown = 0,
		color = {love.math.random(155) + 100, love.math.random(155) + 100, love.math.random(155) + 100},
		no_hit = 128 / 60,
		cut_state = 0}
	return (player)
end

function reset_player(player)
	player["alive"] = 1
	player["pos_x"] = 0
	player["pos_y"] = 0
	player["speed"] = 0.1
	player["life"] = 100
	player["shield"] = 0
	player["shield_life"] = 3
	player["shoot"] = 0
	player["ammo"] = 4
	player["cooldown"] = 0
	player["no_hit"] = 128 / 60
	player["cut_state"] = 0
	player["scale_x"] = tile_sizex / walk[1]:getWidth()
	player["scale_y"] = tile_sizey / walk[1]:getHeight()
end

function spawn_players(players, map, x_lim, y_lim)
	for i,j in pairs(players) do
		while (players[i]["pos_x"] == 0 and players[i]["pos_y"] == 0) do
			local x = love.math.random(x_lim)
			local y = love.math.random(y_lim)
			if (map[y][x].type == "floor") then
				players[i]["pos_x"] = x + 0.5
				players[i]["pos_y"] = y + 0.5
			end
		end
	end
end

function reload(player, sample)
	if (player["ammo"] < 4) then
		player["ammo"] = 4
		player["cooldown"] = 50 / 60
		sample:play()
	end
end