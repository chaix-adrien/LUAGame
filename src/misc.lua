function get_sprite_scale(sprite, focus) -- prendre focus
	wiew, screen, size = get_focus_result(focus)
	local x = size.w / sprite:getWidth()
	local y = size.h / sprite:getHeight()
	return x, y
end

function get_mob_scale(mob)
	local scale_x = (tile_sizex / mob.sprite[1]:getWidth()) * mob.size.x
	local scale_y = (tile_sizey / mob.sprite[1]:getHeight()) * mob.size.y
	return scale_x, scale_y
end

function get_view_vector(r, divide)
	local vec_x = (math.cos(-(r - math.pi * 3 / 4)) + math.sin(-(r - math.pi * 3 / 4))) / divide
	local vec_y = (math.cos(-(r - math.pi * 3 / 4)) - math.sin(-(r - math.pi * 3 / 4))) / divide
	return vec_x, vec_y
end

function map_to_pixel(x, y, focus)
	if (not focus) then
		return x, y
	end
	wiew, screen, size = get_focus_result(focus)
	if (focus.cam_pos_pix) then
		pos_pix = focus.cam_pos_pix
	else
		pos_pix = {x = 0, y = 0}
	end
	local new_x = pos_pix.x + (x - 1) * size.w
	local new_y = pos_pix.y + (y - 1) * size.h
	return new_x, new_y
end

function get_alive_players()
    local alive = {}
    for i, player in pairs(players) do
        if player["alive"] == 1 then
            table.insert(alive, player)
        end
    end
    return alive
end

function game_ended()
	local alive = 0
	for i, player in pairs(players) do
		alive = alive + player["alive"]
	end
	if (table.getn(players) > 1 and alive == 1) then
		return 1
	else
		return 0
	end
end

function draw_size(img, posx, posy, sizex, sizey, r)
	local scalex = sizex / img:getWidth()
	local scaley = sizey / img:getHeight()
	if r then
		local rr = r
	else
		local rr = 0
	end
	love.graphics.draw(img, posx, posy, rr, scalex, scaley) 
end

function is_on_mob(x, y, mob)
	if (x > (mob.pos.x - mob.size.x / 2) + 0.2 * mob.size.x
			and x < ((mob.pos.x - mob.size.x / 2) + 0.8 * mob.size.x)
			and y > (mob.pos.y - mob.size.y / 2) + 0.2 * mob.size.y
			and y < ((mob.pos.y - mob.size.y / 2) + 0.8 * mob.size.y)) then
		return 1
	else
		return 0
	end
end

function vec_to_r(x, y)
	local r = math.atan2(y, x) + math.pi / 2
	return r
end

function smaller(list)
	local out = nil
	for i, value in pairs(list) do
		if (not out or value < out) then
			out = value
		end
	end
	return out
end

function deal_dammages(entity, damage, no_hit)
	if (not (entity.no_hit and entity.no_hit > 0) and entity.life) then
		entity.life = entity.life - damage
	end
	if (no_hit and entity.no_hit and entity.no_hit < 0) then
		entity.no_hit = no_hit
	end
end