function simplify_map()
    local out = {}
    for y = 1, #map, 1 do
        local to_add = {}
        for x = 1, #(map[y]), 1 do
            if (map[y][x].walkable == 1) then
                table.insert(to_add, 0)
            else
                table.insert(to_add, -1)
            end
        end
        table.insert(out, to_add)
    end
    return (out)
end

function clean_map(tmp_map, to_clean)
    for y = 1, #tmp_map, 1 do
        for x = 1, #(tmp_map[y]), 1 do
            if (tmp_map[y][x] == to_clean) then
                tmp_map[y][x] = 0
            end
        end
    end
end

function maze(player, mob)
    local tmp_map = simplify_map()
    local player_pos = {x = math.floor(player.pos_x), y = math.floor(player.pos_y)}
    local tmp_pos = {x = math.floor(mob.pos.x), y = math.floor(mob.pos.y)}
    local path = {}
    while ((tmp_pos.x ~= player_pos.x) or (tmp_pos.y ~= player_pos.y)) do    
        tmp_map[tmp_pos.y][tmp_pos.x] = #path
        if (player_pos.x > tmp_pos.x and map[tmp_pos.y][tmp_pos.x + 1] == 0) then
            table.insert(path, tmp_pos)        
            tmp_map[tmp_pos.y][tmp_pos.x] = #path + 1
            tmp_pos.x = tmp_pos.x + 1
        elseif (player_pos.x < tmp_pos.x and map[tmp_pos.y][tmp_pos.x - 1] == 0) then
            table.insert(path, tmp_pos)        
            tmp_map[tmp_pos.y][tmp_pos.x] = #path + 1
            tmp_pos.x = tmp_pos.x - 1
        elseif (player_pos.y > tmp_pos.y and map[tmp_pos.y + 1][tmp_pos.x] == 0) then
            table.insert(path, tmp_pos)        
            tmp_map[tmp_pos.y][tmp_pos.x] = #path + 1
            tmp_pos.y = tmp_pos.y + 1
        elseif (player_pos.y < tmp_pos.y and map[tmp_pos.y - 1][tmp_pos.x] == 0) then
            table.insert(path, tmp_pos)        
            tmp_map[tmp_pos.y][tmp_pos.x] = #path + 1
            tmp_pos.y = tmp_pos.y - 1
        elseif (tmp_pos.y > 1 and map[tmp_pos.y - 1][tmp_pos.x] == 0) then
            table.insert(path, tmp_pos)        
            tmp_map[tmp_pos.y][tmp_pos.x] = #path + 1
            tmp_pos.y = tmp_pos.y - 1
        elseif (tmp_pos.y < #map and map[tmp_pos.y + 1][tmp_pos.x] == 0) then
            table.insert(path, tmp_pos)        
            tmp_map[tmp_pos.y][tmp_pos.x] = #path + 1
            tmp_pos.y = tmp_pos.y + 1
        elseif (tmp_pos.x > 1 and map[tmp_pos.y][tmp_pos.x - 1] == 0) then
            table.insert(path, tmp_pos)        
            tmp_map[tmp_pos.y][tmp_pos.x] = #path + 1
            tmp_pos.x = tmp_pos.x - 1
        elseif (tmp_pos.x < #(map[1]) and [tmp_pos.y][tmp_pos.x + 1] == 0) then
            table.insert(path, tmp_pos)
            tmp_map[tmp_pos.y][tmp_pos.x] = #path + 1
            tmp_pos.x = tmp_pos.x + 1
        elseif (#path == 0) then
            return (0)
        else
            clean_map(tmp_map, #path + 1)
            tmp_pos.x = path[#path].x
            tmp_pos.y = path[#path].y
            table.remove(path, #path)
        end
    end
    local to_move = {x = (tmp_pos.x - mob.pos.x), y = (tmp_pos.y - mob.pos.y)}
    to_move.x = (to_move.x / math.abs(to_move.x)) * frame_speed * mob.speed
    to_move.y = (to_move.y / math.abs(to_move.y)) * frame_speed * mob.speed
    mob.pos.x = to_move.x
    mob.pos.y = to_move.y
end
