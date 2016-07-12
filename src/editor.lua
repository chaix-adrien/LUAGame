function restart_editor()
	powerups = {}
	players = {}
	tile_sizex = screen_w / view.w
	tile_sizey = screen_h / view.h
	mobs = create_mobs()
	mobs_side = create_mobs()
	load_mobs()
	reset_blocks_mobs()
	size = 0
	for i, block in pairs(blocks) do
		size = size + 1
	end
	cam = {cam_size = {w = screen_w - (screen_w / 4), h = screen_h},
	pos_x = x_fields / 2, pos_y = y_fields / 2,
	target = nil, -- TODO trouver utilité
	cam_view = {w = 0, h = screen_h / (screen_w / 8)},
	cam_pos_pix = {x = screen_w / 8, y = 0}}
	
	cam.cam_view.w = cam.cam_size.w / 80
	cam.cam_view.h = cam.cam_size.h / 80
	map = gen_map(x_fields + 10, y_fields + 10, 10)

	cam_scroller_block_r = {cam_size = {w = screen_w / 8, h = screen_h},
	pos_x = 1, pos_y = size / 2,
	target = nil, -- TODO trouver utilité
	cam_view = {w = 1, h = screen_h / (screen_w / 8)},
	cam_pos_pix = {x = screen_w - screen_w / 8, y = 0}}
	
	cam_scroller_block_l = {cam_size = {w = screen_w / 8, h = screen_h},
	pos_x = 1, pos_y = size / 2,
	target = nil, -- TODO trouver utilité
	cam_view = {w = 1, h = screen_h / (screen_w / 8)},
	cam_pos_pix = {x = 0, y = 0}}

	block_selec_r = gen_map(1, size, 0)
	block_selec_l = gen_map(1, size, 0)
	y = 0
	for i, block in pairs(blocks) do
		y = y + 1
		block_selec_r[y][1] = recur_copy_table(block)
		block_selec_l[y][1] = recur_copy_table(block)
	end
	size = 0
	for i, block in pairs(mobs_ref) do
		size = size + 1
	end
	cam_scroller_mob_r = {cam_size = {w = screen_w / 8, h = screen_h},
	pos_x = 1, pos_y = size / 2,
	target = nil, -- TODO trouver utilité
	cam_view = {w = 1, h = screen_h / (screen_w / 8)},
	cam_pos_pix = {x = screen_w - screen_w / 8, y = 0}}
	
	cam_scroller_mob_l = {cam_size = {w = screen_w / 8, h = screen_h},
	pos_x = 1, pos_y = size / 2,
	target = nil, -- TODO trouver utilité
	cam_view = {w = 1, h = screen_h / (screen_w / 8)},
	cam_pos_pix = {x = 0, y = 0}}

	mob_selec_l = gen_map(1, size, 0)
	mob_selec_r = gen_map(1, size, 0)
	y = 0

	for i, mob in pairs(mobs_ref) do
		y = y + 1
		mob_selec_l[y][1] = recur_copy_table(blocks.floor)
		mob_selec_r[y][1] = recur_copy_table(blocks.floor)
		spawn_mob(mobs_side, mob.type, 1.5, y + 0.5, nil, 0)		
	end
	last_state_click = 0
	mode_l = "block"
	mode_r = "block"
	set_volumes()
end

function editor_keypressed(key)
	if (key == "tab" and alt == 1) then	
		if (mode_r == "block") then mode_r = "mob" else mode_r = "block" end
	elseif (key == "tab") then
		if (mode_l == "block") then mode_l = "mob" else mode_l = "block" end
	end
	if (key == "escape") then
		if (launch_on_menu == 1) then
			for i=0, 1000000000, 1 do tmp = i / 4 end
			go_to_main_menu()
		else
			os.exit()
		end
	end
end

function editor_mousepressed(x, y, button, isTouch)
	lol, lol, mode = get_concerned_side("mouse")
	if (ctrl == 0 and mode == "mob") then
		manage_put_mob()
	end
end

function get_concerned_side(modifier)
	cam_l, cam_r, map_l, map_r = get_concerned_mode()
	if (modifier == "key") then
		if (alt == 1) then
			concerned = cam_r
			concerned_map = map_r
			mode = mode_r
		else
			concerned = cam_l
			concerned_map = map_l
			mode = mode_l
		end
	elseif (modifier == "mouse") then
		if (love.mouse.isDown(2) == true) then
			concerned = cam_r
			concerned_map = map_r
			mode = mode_r
		else
			concerned = cam_l
			concerned_map = map_l
			mode = mode_l
		end
	end
	return concerned, concerned_map, mode
end

function get_concerned_mode()
	if (mode_l == "mob") then
		xcam_l = cam_scroller_mob_l
		xmap_l = mob_selec_l
		xmob_l = mobs_side
	elseif (mode_l == "block") then
		xcam_l = cam_scroller_block_l
		xmap_l = block_selec_l
		xmob_l = nil
	end
	if (mode_r == "mob") then
		xcam_r = cam_scroller_mob_r
		xmap_r = mob_selec_r
		xmob_r = mobs_side
	elseif (mode_r == "block") then
		xcam_r = cam_scroller_block_r
		xmap_r = block_selec_r
		xmob_r = nil
	end
	return xcam_l, xcam_r, xmap_l, xmap_r, xmob_l, xmob_r
end

function set_editor_selec(modifier)
	concerned, concerned_map = get_concerned_side("key")
	if (love.keyboard.isDown("down") == true) then
		concerned.pos_x, concerned.pos_y = move_of({x = concerned.pos_x, y = concerned.pos_y}, {x = 0, y = 1}, 0.1, 1, concerned_map)
	end
	if (love.keyboard.isDown("up") == true) then
		concerned.pos_x, concerned.pos_y = move_of({x = concerned.pos_x, y = concerned.pos_y}, {x = 0, y = -1}, 0.1, 1, concerned_map)
	end
end

function pix_to_map(x, y, focus)
	wiew, screen, size = get_focus_result(focus)
	local nx = (x - focus.cam_pos_pix.x) / size.w + 1
	local ny = (y - focus.cam_pos_pix.y) / size.h + 1
	nx, ny = get_to_draw_map_pos(nx, ny, focus, 1)
	return nx, ny
end

function manage_put_block()
	if (love.mouse.isDown(1) == true or love.mouse.isDown(2) == true) then
		x, y = love.mouse.getPosition()
		concerned, concerned_map = get_concerned_side("mouse")
		x, y = pix_to_map(x, y, cam)
		map[math.floor(y)][math.floor(x)] = recur_copy_table(concerned_map[math.floor(concerned.pos_y)][1])
	end
end

function manage_put_mob()
	if (love.mouse.isDown(1) == true or love.mouse.isDown(2) == true) then
		x, y = love.mouse.getPosition()
		concerned, concerned_map = get_concerned_side("mouse")
		x, y = pix_to_map(x, y, cam)
		nav = 0
		for i, mob in pairs(mobs_ref) do
			nav = nav + 1
			if (nav == math.floor(concerned.pos_y)) then
				mob_to_add = mob
				break
			end
		end
		spawn_mob(mobs, mob_to_add.type, x, y)
	end
end

function manage_move_editor()
	if (ctrl == 1 and love.mouse.isDown(1) == true and last_state_click == 0) then
		last_mouse_pos_x, last_mouse_pos_y = love.mouse.getPosition()
		last_state_click = 1
	end
	if (love.mouse.isDown(1) == false and last_state_click == 1) then
		last_state_click = 0
	end
	if (last_state_click == 1) then
		mx, my = love.mouse.getPosition()
		vx = last_mouse_pos_x - mx
		vy = last_mouse_pos_y - my
		cam.pos_x, cam.pos_y = move_of({x = cam.pos_x, y = cam.pos_y}, {x = vx, y = vy}, math.sqrt(math.pow(vx, 2) + math.pow(vy, 2)) * 0.01, 1)
		last_mouse_pos_x = mx
		last_mouse_pos_y = my
	end
end

function update_editor(dt)
	if ((love.keyboard.isDown("rctrl") == true or love.keyboard.isDown("lctrl") == true)) then ctrl = 1 else ctrl = 0 end
	if ((love.keyboard.isDown("rshift") == true or love.keyboard.isDown("lshift") == true)) then alt = 1 else alt = 0 end
	if (ctrl == 1) then
		if (love.keyboard.isDown("down") == true) then
			if (cam.cam_view.w + screen_w * 0.001 < cam.x_fields) then
				cam.cam_view.w = cam.cam_view.w + screen_w * 0.001
				cam.cam_view.h = cam.cam_view.h + screen_h * 0.001
			end
		end
		if (love.keyboard.isDown("up") == true) then
			if (cam.cam_view.w - screen_w * 0.001 > cam.cam_size.w / 80) then
				cam.cam_view.w = cam.cam_view.w - screen_w * 0.001
				cam.cam_view.h = cam.cam_view.h - screen_h * 0.001
			end
		end
	else
		set_editor_selec()
	end
	manage_move_editor()
	lol, lol, mode = get_concerned_side("mouse")
	if (last_state_click == 0) then
		if (mode == "block") then
			manage_put_block()
		end
	end
	
end

function draw_editor()
	draw_map(map, cam, nil, nil, mobs)
	concerned_l, concerned_r, concerned_map_l, concerned_map_r, mob_draw_l, mob_draw_r = get_concerned_mode("mouse")
	draw_map(concerned_map_l, concerned_l, nil, nil, mob_draw_l)
	draw_map(concerned_map_r, concerned_r, nil, nil, mob_draw_r)
	love.graphics.setLineWidth(10)
	love.graphics.setColor(10, 10, 10, 255)
	love.graphics.line(screen_w / 8, 0, screen_w / 8, screen_h)
	love.graphics.line(screen_w - screen_w / 8, 0, screen_w - screen_w / 8, screen_h)
	love.graphics.setColor(255, 255, 255, 255)
	local px, py = map_to_pix(concerned_l.pos_x, concerned_l.pos_y - 0.5, concerned_l)
	if (py < 0) then py = 0 end
	if (py > screen_h - screen_w / 8) then py = screen_h - screen_w / 8 end
	love.graphics.rectangle("line", px, py, screen_w / 8, screen_w / 8)
	local px, py = map_to_pix(concerned_r.pos_x, concerned_r.pos_y - 0.5, concerned_r)
	if (py < 0) then py = 0 end
	if (py > screen_h - screen_w / 8) then py = screen_h - screen_w / 8 end
	love.graphics.rectangle("line", px, py, screen_w / 8, screen_w / 8)
end