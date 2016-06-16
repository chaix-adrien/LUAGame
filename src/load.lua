function copy_table(tb)
	copy = {}
	for i, value in pairs(tb) do
		copy[i] = value
	end
	return (copy)
end

function gen_map(x, y, rate)
	map = {}
	for i = 1, y, 1 do
		local to_add = {}
		for j = 1, x, 1 do
			if (love.math.random(rate) == rate - 1) then
				table.insert(to_add, copy_table(blocks.wall))
        -- BLOC PIMP
			elseif (love.math.random(rate / 2) == ((rate / 2) - 1)) then
				table.insert(to_add, copy_table(blocks.brick))
			elseif (love.math.random(rate) == ((rate) - 1)) then
				table.insert(to_add, copy_table(blocks.hole))
			elseif (love.math.random(rate) == ((rate) - 1)) then
				table.insert(to_add, copy_table(blocks.mud))
			elseif (love.math.random(rate) == ((rate) - 1)) then
				table.insert(to_add, copy_table(blocks.inflamable))
			elseif (love.math.random(rate * 4) == ((rate))) then
				table.insert(to_add, copy_table(blocks.tnt))
			elseif (love.math.random(rate * 4) == ((rate))) then
				table.insert(to_add, copy_table(blocks.electric_box))
			elseif (love.math.random(rate * 4) == ((rate))) then
				table.insert(to_add, copy_table(blocks.waterbomb))
			elseif (love.math.random(rate * 20) == ((rate))) then
				table.insert(to_add, copy_table(blocks.chest))
			else
				table.insert(to_add, copy_table(blocks.floor))
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

function reset_blocks()
	if (blocks) then
		for i, block in pairs(blocks) do
				for j, sprite in pairs(block.sprite) do
					block["scale_x"], block["scale_y"] = get_sprite_scale(sprite)
				end
		end
	end
	powerup_life_block.scale_x, powerup_life_block.scale_y = get_sprite_scale(powerup_life_block.sprite)
	powerup_ammo_block.scale_x, powerup_ammo_block.scale_y = get_sprite_scale(powerup_ammo_block.sprite)
	powerup_invincible_block.scale_x, powerup_invincible_block.scale_y = get_sprite_scale(powerup_invincible_block.sprite)
	powerup_shield_block.scale_x, powerup_shield_block.scale_y = get_sprite_scale(powerup_shield_block.sprite)
end

function  restart()
	powerups = {}
	joysticks = love.joystick.getJoysticks()
	if (table.getn(joysticks) < 1) then return 1 end
	x_fields = 16
	y_fields = 9
	tile_sizex = screen_w / x_fields
	tile_sizey = screen_h / y_fields
	reset_blocks()	
	load_player_joystick()
	map = gen_map(x_fields, y_fields, 10)
	spawn_players(players, map, x_fields, y_fields)
	game_victory = 0
	item_spawn = item_spawn_rate
	set_volumes()
	create_mobs()
	table.insert(mobs.zombie, copy_table(mobs_ref.zombie))
	return 0
end

function load_block(typeof, sprites, walkability, cross, animate, status, frames, shoot, walk, cut)
	sx, sy = get_sprite_scale(sprites[1])
	local block = {type = typeof, sprite = sprites, scale_x = sx, scale_y = sy, walkable = walkability, animated = animate, state = status, frame = frames, shooted_on = shoot, walked_on = walk, cut_on = cut, crossable = cross}
	return (block)
end

function load_powerup(typeof, name, walkability, cross, walk)
	local img = love.graphics.newImage(name)
	sx, sy = get_sprite_scale(img)
	local powerup = {type = typeof, sprite = img, scale_x = sx, scale_y = sy, walkable = walkability, walked_on = walk}
	return (powerup)
end

function  load_blocks()
    blocks = {floor = load_block("floor", {love.graphics.newImage("block/floor.png")}, 1, 1, 0, 0, 1, shoot_on_nothing, reset_status, cut_on_nothing),
	    brick = load_block("brick", {love.graphics.newImage("block/brick.png"), love.graphics.newImage("block/broken_brick.png")},
		0, 0, 0, 0, 1, shoot_on_brick, reset_status, shoot_on_brick),
        wall = load_block("wall", {love.graphics.newImage("block/wall.png")}, 0, 0, 0, 0, 1, shooted_on_nothing, reset_status, cut_on_nothing),
        hole = load_block("hole", {love.graphics.newImage("block/hole.png")}, 0, 1, 0, 0, 1, shooted_on_nothing, reset_status, cut_on_nothing),
        mud = load_block("mud", {love.graphics.newImage("block/mud.png")}, 1, 1, 0, 0, 1, shooted_on_nothing, mud, cut_on_nothing),
        fire = load_block("fire", fire_sprite, 1, 1, 1, fire_time, 1, shooted_on_nothing, fire_damage, cut_on_nothing),
        inflamable = load_block("inflamable", {love.graphics.newImage("block/inflamable.png")}, 0, 0, 0, 0, 1, break_box, reset_status, break_box),
        tnt = load_block("tnt", {love.graphics.newImage("block/tnt.png")}, 0, 0, 0, 0, 1, explode, reset_status, explode),
        waterbomb = load_block("waterbomb", waterbomb_sprite, 1, 0, 1, 0, 1, waterbomb, waterbomb, waterbomb),
        bolt_ball = load_block("bolt_ball", electric_sprite, 1, 1, 1, fire_time, 1, shooted_on_nothing, electric_damage, cut_on_nothing),
        electric_box = load_block("electric_box", electric_box_sprite, 0, 0, 1, 0, 1, electric_explode, reset_status, electric_explode),
		chest = load_block("chest", {love.graphics.newImage("block/coffre.png")}, 0, 0, 0, 0, 1, shooted_on_nothing, reset_status, open_chest)}

		powerup_life_block = load_powerup("PU_life", "block/life.png", 1, 1, powerup_life)
		powerup_shield_block = load_powerup("PU_shield", "block/shield.png", 1, 1, powerup_shield)
		powerup_ammo_block = load_powerup("PU_ammo", "block/ammo.png", 1, 1, powerup_ammo)
		powerup_invincible_block = load_powerup("PU_invincible", "block/invincible.png", 1, 1,powerup_invincible)
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
	electric_box_sprite = {}
	for i = 1, 10, 1 do
		table.insert(electric_box_sprite, love.graphics.newImage("block/bolt_sizzle/bolt_sizzle_000" .. tostring(i) .. ".png"))
	end
	waterbomb_sprite = {}
	for i = 1, 8, 1 do
		table.insert(waterbomb_sprite, love.graphics.newImage("block/waterbomb/" .. tostring(i) .. ".jpg"))
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

function set_volumes()
	music_volume = option_menu.slides[1].value
	sound_volume = option_menu.slides[2].value
	music:setVolume(0.7 * music_volume)
	laser:setVolume(0.4 * sound_volume)
	shield_sound:setVolume(0.4 * sound_volume)
	shield_break_sound:setVolume(1 * sound_volume)
	powerup_life_sound:setVolume(1 * sound_volume)
	powerup_shield_sound:setVolume(1 * sound_volume)
	laser2:setVolume(1 * sound_volume)
	reload_sound:setVolume(1 * sound_volume)
	tnt_sound:setVolume(1 * sound_volume)
	waterbomb_sound:setVolume(0.5 * sound_volume)
	win_sound:setVolume(1 * sound_volume)
	box_sound:setVolume(1 * sound_volume)
	cut_sound:setVolume(1 * sound_volume)
	electric_explode_sound:setVolume(0.7 * sound_volume)
	item_spawn_sound:setVolume(1 * sound_volume)
end

function load_sounds()
	--                    WALK  - FIRE
	music = load_sound("music/music" .. tostring(math.random(4)) .. ".mp3", 0.7)
	music:setLooping(true)
	music:play()
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

function move_mob_fix(mob, dt)
	return nil
end

function update_mob_only_frame(mob, dt)
	mob.frame = mob.frame + 2 * frame_speed
	if (mob.frame > #mob.sprite) then
		mob.frame = 1
	end
	--temp
	mob.r = mob.r + 0.1
	--
end


function move_mob_rand(mob)
	mob.pos.x = mob.pos.x + math.random() * 0.1
	mob.pos.y = mob.pos.y + math.random() * 0.1
	-- TODO true rand verifier pos until
end

function walk_mob_hit(player, mob)
	player.life = player.life - 20
	player.no_hit = 1
end

function draw_mob_basic(mob)
	print(mob.r)
	px, py = map_to_pixel(mob.pos.x, mob.pos.y)
	px, py = rotate_pos(px, py, mob.r, mob.sprite[math.floor(mob.frame)])
	love.graphics.draw(mob.sprite[math.floor(mob.frame)], px, py, mob.r, mob.scale.x, mob.scale.y)
end



function load_mob(nam, lif, sprit, statu, fram, spee, update_mov, update_mo, draw_mo, shoot_o, move_o, cut_o, walkab, crossab, size_x, size_y, pos_x, pos_y)
	local mob = {type = nam,
				life = lif,
				sprite = sprit,
				status = statu,
				frame = fram,
				speed = spee,
				move = update_mov,
				update = update_mo,
				draw = draw_mo,
				shooted_on = shoot_o, 
				walked_on = move_o,
				cut_on = cut_o,
				walkable = walkab, 
				crossable = crossab,
				r = 0,
				size = {x = size_x, y = size_y},
				pos = {x = pos_x, y = pos_y},
				scale = {x = (tile_sizex / sprit[1]:getWidth() * size_x), y = (tile_sizey / sprit[1]:getHeight() * size_y)}}
	return (mob)
end

function create_mobs()
	mobs = {}
	for i, mob in pairs(mobs_ref) do
		mobs[mob.type] = {}
	end
end

function load_mobs()
	mobs_ref = {zombie = load_mob("zombie", 100, electric_box_sprite, 0, 1, 1, move_mob_fix, update_mob_only_frame, draw_mob_basic, shoot_on_nothing, walk_mob_hit, cut_on_nothing, 0, 0, 1, 1, 5, 5)}
end

function launch_quick_party()
	if (restart() == 1) then
		return
	end
	love.update = update_game
	love.draw = draw_game
end

function love.load()
	math.randomseed(os.time())
	walk = {love.graphics.newImage("misc/walk_one.png"), love.graphics.newImage("misc/walk_two.png"),
	love.graphics.newImage("misc/walk_three.png"), love.graphics.newImage("misc/walk_two.png")}
	tile_sizex = screen_w / x_fields
	tile_sizey = screen_h / y_fields
    load_animation()
	load_blocks()
	load_impact()
	load_sounds()
	load_mobs()
	load_gui()
	powerups = {}
	love.window.setMode(screen_w, screen_h)
	love.window.setFullscreen(fullscreen, "exclusive")
	load_mobs()
	if (launch_on_menu == 1) then
		launch_menu(main_menu)
	else
		launch_quick_party()
	end
end