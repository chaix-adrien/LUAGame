function get_sprite_scale(sprite)
	local x = tile_sizex / sprite:getWidth()
	local y = tile_sizey / sprite:getHeight()
	return x, y
end

function get_view_vector(value)
	local vec_x = (math.cos(-(value["r"] - math.pi * 3 / 4)) * tile_sizex + math.sin(-(value["r"] - math.pi * 3 / 4)) * tile_sizey) / 10
	local vec_y = (math.cos(-(value["r"] - math.pi * 3 / 4)) * tile_sizey - math.sin(-(value["r"] - math.pi * 3 / 4)) * tile_sizex) / 10
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
