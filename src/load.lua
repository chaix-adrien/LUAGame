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

function reset_blocks_mobs()
	if (blocks) then
		for i, block in pairs(blocks) do
				for j, sprite in pairs(block.sprite) do
					block["scale_x"], block["scale_y"] = get_sprite_scale(sprite)
				end
		end
	end
	if (mobs_ref) then
		for i, mob in pairs(mobs_ref) do
			mob.scale.x, mob.scale.y = get_mob_scale(mob)
		end
	end
	powerup_life_block.scale_x, powerup_life_block.scale_y = get_sprite_scale(powerup_life_block.sprite)
	powerup_ammo_block.scale_x, powerup_ammo_block.scale_y = get_sprite_scale(powerup_ammo_block.sprite)
	powerup_invincible_block.scale_x, powerup_invincible_block.scale_y = get_sprite_scale(powerup_invincible_block.sprite)
	powerup_shield_block.scale_x, powerup_shield_block.scale_y = get_sprite_scale(powerup_shield_block.sprite)
end

function concat_name(l1, l2)
	local out = {}
	if (type(l1) == "table") then
		for i, value in pairs(l1) do
			out[i] = value
		end
	else
		table.insert(out, l1)
	end
	for i, value in pairs(l2) do
		out[i] = l2[i]
	end
	return out
end

function spawn_mob(type, px, py, state, rot, target, color) -- TODO faire des creation de liste puis insert pour pouvoir mettre stat par defaut dans mob_ref
	table.insert(mobs[type], copy_table(mobs_ref[type]))
	mobs[type][#(mobs[type])].pos.x = px
	mobs[type][#(mobs[type])].pos.y = py
	mobs[type][#(mobs[type])].r = rot
	mobs[type][#(mobs[type])].target = target
	if (state) then
		mobs[type][#(mobs[type])].state = concat_name(mobs[type][#(mobs[type])].state, state)
	end
	mobs[type][#(mobs[type])].color = color	
end

function  restart_pvp()
	powerups = {}
	joysticks = love.joystick.getJoysticks()
	if (table.getn(joysticks) < 1) then return 1 end
	tile_sizex = screen_w / x_fields -- TODO : si map < ratio screen, calculler tile size autrement pour que block carré, add pos map par rapport a l'ecran
	tile_sizey = screen_h / y_fields
	reset_blocks_mobs()
	load_player_joystick()
	map = gen_map(x_fields, y_fields, 10)
	spawn_players(players, map, x_fields, y_fields)
	game_victory = 0
	item_spawn = item_spawn_rate
	set_volumes()
	create_mobs()
	--spawn_mob("turret_fixed", 3.5, 3.5, nil, math.pi * 0.75)
	--spawn_mob("turret_target", 7.5, 7.5, nil, 0, players[1], {255, 100, 100, 255})
	--spawn_mob("turret_target_mobile", 9.5, 7.5, nil, 0, players[1], {255, 255, 100, 255})
	--spawn_mob("turret_rot", 10.5, 7.5, nil, 0, nil, {100, 100, 255, 255})
	return 0
end

function restart_editor()
	powerups = {}
	players = {}
	tile_sizex = screen_w / view.w
	tile_sizey = screen_h / view.h
	reset_blocks_mobs()
	print("Load editor")
	cam = {pos_x = x_fields / 2, pos_y = y_fields / 2, target = nil, cam_view = {w = x_fields, h = y_fields}}
	map = gen_map(x_fields, y_fields, 0)
	set_volumes()
	create_mobs()
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

function create_mobs()
	mobs = {}
	for i, mob in pairs(mobs_ref) do
		mobs[mob.type] = {}
	end
end

function load_mob(nam, lif, sprit, statu, fram, spee, update_mov, update_mo, draw_mo, shoot_o, move_o, cut_o, crossab, size_x, size_y, pos_x, pos_y, rot)
	local mob = {type = nam,
				life = lif,
				sprite = sprit,
				state = statu,
				frame = fram,
				speed = spee,
				move = update_mov,
				update = update_mo,
				draw = draw_mo,
				shooted_on = shoot_o, 
				walked_on = move_o,
				cuted_on = cut_o,
				crossable = crossab,
				r = rot,
				target = nil,
				size = {x = size_x, y = size_y},
				pos = {x = pos_x, y = pos_y},
				color = nil,
				scale = {x = (tile_sizex / sprit[1]:getWidth() * size_x), y = (tile_sizey / sprit[1]:getHeight() * size_y)}}
	return (mob)
end

function concat(l1, l2)
	local lim = #l2
	for i = 1, lim, 1 do
		table.insert(l1, l2[i])
	end
	return l1
end

function load_mobs()
	turret_sprite = love.graphics.newImage("mob/turret.png")
	turret_move_sprite = {}
	for i = 1, 4, 1 do
		table.insert(turret_move_sprite, love.graphics.newImage("mob/turret_walk" .. i .. ".png"))
	end
	mobs_ref = {zombie = load_mob("zombie", 100, electric_box_sprite, 0, 1, 1,
	nil_func, update_mob_only_frame, draw_mob_basic, kill_mob, walk_mob_hit, kill_mob, 0, 1, 1, 5, 5, 0),
	turret_fixed = load_mob("turret_fixed", 100, {turret_sprite}, {fire_time = 0, fire_frequency = 2}, 1, 0,
	nil_func, update_turret_fix, draw_mob_basic, kill_mob, nil_func, kill_mob, 0, 1, 1, 5, 5, 0),
	turret_target = load_mob("turret_target", 100, {turret_sprite}, {fire_time = 0, fire_frequency = 2}, 1, 0,
	nil_func, update_turret_target, draw_mob_basic, kill_mob, nil_func, kill_mob, 0, 1, 1, 5, 5, 0),
	turret_rot = load_mob("turret_rot", 100, {turret_sprite}, {fire_time = 0, fire_frequency = 2, min_rot = 0, max_rot = math.pi / 2, side = 1}, 1, 0,
	nil_func, update_turret_rot, draw_mob_basic, kill_mob, nil_func, kill_mob, 0, 1, 1, 5, 5, 0),
	turret_target_mobile = load_mob("turret_target_mobile", 100, concat({turret_sprite}, turret_move_sprite),
	{fire_time = 0, fire_frequency = 1, mode = 0, mode_time = 1, turret_time = 5, cycle_time = 10}, 1, 0.5, -- TODO, prise en compte de speed
	move_turret_target_mobile, update_turret_target_mobile, draw_mob_basic, kill_mob, nil_func, kill_mob, 0, 1, 1, 5, 5, 0)}
end

function launch_quick_party()
	view.x = x_fields
	view.y = y_fields
	if (restart_pvp() == 1) then
		return
	end
	love.update = update_game
	love.draw = draw_game
end

function launch_editor(x, y)
	print("Launch editor")
	view.x = x_fields
	view.y = y_fields
	if (restart_editor() == 1) then
		return
	end
	love.update = update_editor
	love.draw = draw_editor
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
	export_list(mobs_ref, "tachatte.txt", "mobs_ref")
	local mylist = import_list("tachatte.txt")
	print(m)
	export_list(mylist, "tamere.txt", "mylist")
	love.window.setMode(screen_w, screen_h)
	love.window.setFullscreen(fullscreen, "exclusive")
	load_mobs()
	print(launch_on)
	if (launch_on == "menu") then
		launch_menu(main_menu)
	elseif (launch_on == "pvp") then
		launch_quick_party()
	elseif (launch_on == "editor") then
		launch_editor(x_fields, y_fields)
	end
end