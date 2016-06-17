function get_sprite_scale(sprite)
	if (not tile_sizex or not tile_sizey) then
		return 0, 0
	end
	local x = tile_sizex / sprite:getWidth()
	local y = tile_sizey / sprite:getHeight()
	return x, y
end

function get_view_vector(r, divide)
	local vec_x = (math.cos(-(r - math.pi * 3 / 4)) + math.sin(-(r - math.pi * 3 / 4))) / divide
	local vec_y = (math.cos(-(r - math.pi * 3 / 4)) - math.sin(-(r - math.pi * 3 / 4))) / divide
	return vec_x, vec_y
end

function map_to_pixel(x, y)
	local new_x = (x - 1) * tile_sizex
	local new_y = (y - 1) * tile_sizey
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