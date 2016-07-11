function restart_editor()
	powerups = {}
	players = {}
	tile_sizex = screen_w / view.w
	tile_sizey = screen_h / view.h
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
	
	cam_scroller_r = {cam_size = {w = screen_w / 8, h = screen_h},
	pos_x = 1, pos_y = size / 2,
	target = nil, -- TODO trouver utilité
	cam_view = {w = 1, h = screen_h / (screen_w / 8)},
	cam_pos_pix = {x = screen_w - screen_w / 8, y = 0}}
	
	cam_scroller_l = {cam_size = {w = screen_w / 8, h = screen_h},
	pos_x = 1, pos_y = size / 2,
	target = nil, -- TODO trouver utilité
	cam_view = {w = 1, h = screen_h / (screen_w / 8)},
	cam_pos_pix = {x = 0, y = 0}}
	cam.cam_view.w = cam.cam_size.w / 80
	cam.cam_view.h = cam.cam_size.h / 80
	--if (cam.cam_view.w < 16) then cam.cam_view.w = 16 end
	--if (cam.cam_view.h < 9) then cam.cam_view.h = 9 end
	map = gen_map(x_fields + 10, y_fields + 10, 10)
	
	block_selec_r = gen_map(1, size, 0)
	block_selec_l = gen_map(1, size, 0)
	y = 0
	for i, block in pairs(blocks) do
		y = y + 1
		block_selec_r[y][1] = copy_table(block)
		block_selec_l[y][1] = copy_table(block)
	end
	set_volumes()
	create_mobs()
end


function get_concerned_side(modifier)
	if (modifier == "key") then
		if (love.keyboard.isDown("ralt") == true or love.keyboard.isDown("lalt") == true) then
			concerned = cam_scroller_r
			concerned_map = block_selec_r
		else
			concerned = cam_scroller_l
			concerned_map = block_selec_l
		end
	elseif (modifier == "mouse") then
		if (love.mouse.isDown(2) == true) then
			concerned = cam_scroller_r
			concerned_map = block_selec_r
		else
			concerned = cam_scroller_l
			concerned_map = block_selec_l
		end
	end
	return concerned, concerned_map
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

function update_editor(dt)
	set_editor_selec()
	if (love.mouse.isDown(1) == true or love.mouse.isDown(2) == true) then
		x, y = love.mouse.getPosition()
		concerned, concerned_map = get_concerned_side("mouse")
		x, y = pix_to_map(x, y, cam)
		map[math.floor(y)][math.floor(x)] = copy_table(concerned_map[math.floor(concerned.pos_y)][1])
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

function draw_editor()
	draw_map(map, cam)	
	draw_map(block_selec_r, cam_scroller_r)
	draw_map(block_selec_l, cam_scroller_l)
	love.graphics.setLineWidth(10)
	love.graphics.setColor(10, 10, 10, 255)
	love.graphics.line(screen_w / 8, 0, screen_w / 8, screen_h)
	love.graphics.line(screen_w - screen_w / 8, 0, screen_w - screen_w / 8, screen_h)
	love.graphics.setColor(255, 255, 255, 255)
	local px, py = map_to_pix(cam_scroller_l.pos_x, cam_scroller_l.pos_y - 0.5, cam_scroller_l)
	if (py < 0) then py = 0 end
	if (py > screen_h - screen_w / 8) then py = screen_h - screen_w / 8 end
	love.graphics.rectangle("line", px, py, screen_w / 8, screen_w / 8)
	local px, py = map_to_pix(cam_scroller_r.pos_x, cam_scroller_r.pos_y - 0.5, cam_scroller_r)
	if (py < 0) then py = 0 end
	if (py > screen_h - screen_w / 8) then py = screen_h - screen_w / 8 end
	love.graphics.rectangle("line", px, py, screen_w / 8, screen_w / 8)
end
