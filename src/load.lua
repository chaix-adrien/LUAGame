function gen_map(x, y, rate)
	map = {}
	for i = 1, y, 1 do
		local to_add = {}
		for j = 1, x, 1 do
			if (love.math.random(rate) == rate - 1) then
				table.insert(to_add, 4)
        -- BLOC PIMP
			elseif (love.math.random(rate / 2) == ((rate / 2) - 1)) then
				table.insert(to_add, 3)
			elseif (love.math.random(rate) == ((rate) - 1)) then
				table.insert(to_add, 5)
			elseif (love.math.random(rate) == ((rate) - 1)) then
				table.insert(to_add, 6)
			elseif (love.math.random(rate) == ((rate) - 1)) then
				table.insert(to_add, 8)
			elseif (love.math.random(rate * 4) == ((rate))) then
				table.insert(to_add, 9)
			elseif (love.math.random(rate * 4) == ((rate))) then
				table.insert(to_add, 10)
			elseif (love.math.random(rate * 4) == ((rate))) then
				table.insert(to_add, 14)
			elseif (love.math.random(rate * 20) == ((rate))) then
				table.insert(to_add, 15)
			else
				table.insert(to_add, 1)
			end
		end
		table.insert(map, to_add)
	end
	return (map)
end

function load_player_joystick()
	if (not players) then players = {} end
	for i, value in pairs(joysticks) do	
		if (i > table.getn(players)) then	
			table.insert(players, create_player("player" .. tostring(i), walk[1]))
		else
			reset_player(players[i])
		end
	end
	local i = table.getn(joysticks)
	while (i < table.getn(players)) do
		i = i + 1
		table.remove(players, i)
	end
end

function  restart()
	item_spawn = 600
	fire_blocks = {}
	electric_blocks = {}
	joysticks = love.joystick.getJoysticks()
	if (table.getn(joysticks) < 1) then os.exit() end
	x_fields = 16
	y_fields = 9
	tile_sizex = screen_w / x_fields
	tile_sizey = screen_h / y_fields
	if (blocks) then
		for i, block in pairs(blocks) do
			block["scale_x"], block["scale_y"] = get_sprite_scale(block["sprite"])
		end
	end
	load_player_joystick()
	map = gen_map(x_fields, y_fields, 10)
	spawn_players(players, map, x_fields, y_fields)
	game_victory = 0
end

function load_block(name, walkability, cross, shoot, walk, cut)
	local img = love.graphics.newImage(name)
	sx, sy = get_sprite_scale(img)
	local block = {sprite = img, scale_x = sx, scale_y = sy, walkable = walkability, shooted_on = shoot, walked_on = walk, cut_on = cut, crossable = cross}
	return (block)
end

function  load_blocks()
    blocks = {load_block("block/floor.png", 1, 1, shooted_on_nothing, reset_status, cut_on_nothing),
	    load_block("block/broken_brick.png", 0, 0, shoot_on_brick, reset_status, shoot_on_brick),
        load_block("block/brick.png", 0, 0, shoot_on_brick, reset_status, shoot_on_brick),
        load_block("block/wall.png", 0, 0, shooted_on_nothing, reset_status, cut_on_nothing),
        load_block("block/hole.png", 0, 1, shooted_on_nothing, reset_status, cut_on_nothing),
        load_block("block/mud.png", 1, 1, shooted_on_nothing, mud, cut_on_nothing),
        load_block("block/fire_ball/fire1.png", 1, 1, shooted_on_nothing, fire_damage, cut_on_nothing),
        load_block("block/inflamable.png", 0, 0, break_box, reset_status, break_box),
        load_block("block/tnt.png", 0, 0, explode, reset_status, explode),
        load_block("block/waterbomb.png", 1, 0, waterbomb, waterbomb, waterbomb),
        load_block("block/life.png", 1, 0, turn_block_to_floor, powerup_life, turn_block_to_floor),
        load_block("block/shield.png", 1, 0, turn_block_to_floor, powerup_shield, turn_block_to_floor),
        load_block("block/bolt_ball/bolt_ball_0001.png", 1, 1, shooted_on_nothing, electric_damage, cut_on_nothing),
        load_block("block/electric_box.png", 0, 0, electric_explode, reset_status, electric_explode)}
end

function load_animation()
    fire_sprite = {}
	for i = 1, 6, 1 do
		table.insert(fire_sprite, love.graphics.newImage("block/fire_ball/fire" .. tostring(i) .. ".png"))
	end
	fireworks = {}
	for i = 1, 4, 1 do
		table.insert(fireworks, love.graphics.newImage("impact/firework" .. tostring(i) .. ".png"))
	end
	electric_sprite = {}
	for i = 1, 6, 1 do
		table.insert(electric_sprite, love.graphics.newImage("block/bolt_ball/bolt_ball_000" .. tostring(i) .. ".png"))
	end
end

function load_impact()
    sprite_impact = love.graphics.newImage("impact/impact2.png")
	sprite_skull = love.graphics.newImage("impact/skull.png")
	win_screen = love.graphics.newImage("misc/winner.png")
end

function load_sound(name, volume, mode)
    local sound = love.audio.newSource(name, mode)
    sound:setVolume(volume)
    return sound
end

function load_sounds()
	--                    WALK  - FIRE
	music = load_sound("music/music" .. tostring(math.random(4)) .. ".mp3", 0.7)
	music:setLooping(true)
    laser = load_sound("soundeffect/laser.wav", 0.4, "stream")
	shield_sound = load_sound("soundeffect/shield_impact.wav", 0.4, "stream")
	shield_break_sound = load_sound("soundeffect/break_shield.wav", 1, "stream")
	powerup_life_sound = load_sound("soundeffect/food.wav", 1, "stream")
	powerup_shield_sound = load_sound("soundeffect/shield.wav", 1, "stream")
	laser2 = load_sound("soundeffect/laser2.wav", 1, "stream")
	reload_sound = load_sound("soundeffect/reload.mp3", 1, "stream")
	tnt_sound = load_sound("soundeffect/tnt.wav", 1, "stream")
	waterbomb_sound = load_sound("soundeffect/waterbomb.wav", 0.5, "stream")
	win_sound = load_sound("soundeffect/winner.wav", 1, "stream")
	box_sound = load_sound("soundeffect/box.wav", 2, "stream")
	cut_sound = load_sound("soundeffect/cut.mp3", 1, "stream")
	electric_explode_sound = load_sound("soundeffect/electric_explode.wav", 0.7, "stream")
	item_spawn_sound = load_sound("soundeffect/item_spawn.wav", 1, "stream")
end

function love.load()
	math.randomseed(os.time())
	walk = {love.graphics.newImage("misc/walk_one.png"), love.graphics.newImage("misc/walk_two.png"),
	love.graphics.newImage("misc/walk_three.png"), love.graphics.newImage("misc/walk_two.png")}
	restart()
	load_blocks()
    load_animation()
	load_impact()
	load_sounds()
	love.window.setMode(screen_w, screen_h)
	love.window.setFullscreen(fullscreen, "exclusive")
end