function simplify_map()
    local out = {}
    for y = 1, #map, 1 do
    print("for")
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

function nearest()
    local out = players[1]
    for i = 1, #players, 1 do
        if (math.sqrt(math.pow(players[i].pos_x, 2) + math.pow(players[i].pos_y, 2)) < math.sqrt(math.pow(out.pos_x, 2) + math.pow(out.pos_y, 2))) then
            out = players[i]
        end
    end
    return (out)
end

function maze(mob)
    --print("hello", mob.pos.x, mob.pos.y)
    local player = nearest()
    local tmp_map = simplify_map()
    local player_pos = {x = math.floor(player.pos_x), y = math.floor(player.pos_y)}
    local tmp_pos = {x = math.floor(mob.pos.x), y = math.floor(mob.pos.y)}
    local path = {}
    local limit = 0
    while ((tmp_pos.x ~= player_pos.x) or (tmp_pos.y ~= player_pos.y)) do  
        --print("pos x and y", tmp_pos.x, tmp_pos.y)  
        tmp_map[tmp_pos.y][tmp_pos.x] = #path
        if (player_pos.x > tmp_pos.x and tmp_map[tmp_pos.y][tmp_pos.x + 1] == 0) then
            table.insert(path, tmp_pos)        
            tmp_map[tmp_pos.y][tmp_pos.x] = #path + 1
            tmp_pos.x = tmp_pos.x + 1
        elseif (player_pos.x < tmp_pos.x and tmp_map[tmp_pos.y][tmp_pos.x - 1] == 0) then
            table.insert(path, tmp_pos)        
            tmp_map[tmp_pos.y][tmp_pos.x] = #path + 1
            tmp_pos.x = tmp_pos.x - 1
        elseif (player_pos.y > tmp_pos.y and tmp_map[tmp_pos.y + 1][tmp_pos.x] == 0) then
            table.insert(path, tmp_pos)        
            tmp_map[tmp_pos.y][tmp_pos.x] = #path + 1
            tmp_pos.y = tmp_pos.y + 1
        elseif (player_pos.y < tmp_pos.y and tmp_map[tmp_pos.y - 1][tmp_pos.x] == 0) then
            table.insert(path, tmp_pos)        
            tmp_map[tmp_pos.y][tmp_pos.x] = #path + 1
            tmp_pos.y = tmp_pos.y - 1
        elseif (tmp_pos.y > 1 and tmp_map[tmp_pos.y - 1][tmp_pos.x] == 0) then
            table.insert(path, tmp_pos)        
            tmp_map[tmp_pos.y][tmp_pos.x] = #path + 1
            tmp_pos.y = tmp_pos.y - 1
        elseif (tmp_pos.y < #map and tmp_map[tmp_pos.y + 1][tmp_pos.x] == 0) then
            table.insert(path, tmp_pos)        
            tmp_map[tmp_pos.y][tmp_pos.x] = #path + 1
            tmp_pos.y = tmp_pos.y + 1
        elseif (tmp_pos.x > 1 and tmp_map[tmp_pos.y][tmp_pos.x - 1] == 0) then
            table.insert(path, tmp_pos)        
            tmp_map[tmp_pos.y][tmp_pos.x] = #path + 1
            tmp_pos.x = tmp_pos.x - 1
        elseif (tmp_pos.x < #(map[1]) and tmp_map[tmp_pos.y][tmp_pos.x + 1] == 0) then
            table.insert(path, tmp_pos)
            tmp_map[tmp_pos.y][tmp_pos.x] = #path + 1
            tmp_pos.x = tmp_pos.x + 1
        elseif (#path == 0) then
            return (0)
        elseif (limit >= 10) then
            break
        else
            clean_map(tmp_map, #path + 1)
            tmp_pos.x = path[#path].x
            tmp_pos.y = path[#path].y
            table.remove(path, #path)
        end
    limit = limit + 1
    end
    if (#path == 0) then
        return (0)
    end
    local to_move = {x = (path[1].x - mob.pos.x), y = (path[1].y - mob.pos.y)}
    to_move.x = (to_move.x / math.abs(to_move.x)) * frame_speed * mob.speed / 3
    to_move.y = (to_move.y / math.abs(to_move.y)) * frame_speed * mob.speed / 3
    --print("frame speed", frame_speed, "mob.speed", mob.speed)
    --print("to move", to_move.x, to_move.y)
    --print("before", mob.pos.x, mob.pos.y)
    local tmp_y = math.floor(mob.pos.y + to_move.y)
    local tmp_x = math.floor(mob.pos.x + to_move.x)
    if (tmp_y > 1 and tmp_y <= #map and map[tmp_y][math.floor(mob.pos.x)].walkable == 1) then
        mob.pos.y = (mob.pos.y + to_move.y)        
    end
    if (tmp_x > 1 and tmp_x <= #(map[1]) and map[math.floor(mob.pos.y)][tmp_x].walkable == 1) then
        mob.pos.x = (mob.pos.x + to_move.x)        
    end    
    --mob.pos.x = mob.pos.x + to_move.x
    --mob.pos.y = mob.pos.y + to_move.y
    --print("after", mob.pos.x, mob.pos.y)        
end
