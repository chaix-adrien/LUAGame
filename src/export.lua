function export_map(filename)
    local file = io.open(filename, "w+")
    io.output(file)
    local header = {x = #(map[1]), y = #map}
    io.write(JSON:encode(header))
    io.write("\n")
    for y = 1, #map, 1 do
        for x = 1, #(map[y]), 1 do
            local tmp = {type = map[y][x].type, state = map[y][x].state, frame = map[y][x].frame}
            io.write(JSON:encode(tmp))
            io.write("\n")            
        end
    end
    io.output(io.stdout)
    io.close(file)
end

function import_map(filename)
    local file = io.open(filename, "r")
    if (file == nil) then return nil end

    io.input(file)

    local header = JSON:decode(io.read())
    local map = {}
    for y = 1, header.y, 1 do
        local to_add = {}
        for x = 1, header.x, 1 do
            local tmp_table = JSON:decode(io.read())
            if (tmp_table.type == "wall") then
                table.insert(to_add, copy_table(blocks.wall))
            elseif (tmp_table.type == "brick") then
                table.insert(to_add, copy_table(blocks.brick))
            elseif (tmp_table.type == "hole") then
                table.insert(to_add, copy_table(blocks.hole))
            elseif (tmp_table.type == "mud") then
                table.insert(to_add, copy_table(blocks.mud))
            elseif (tmp_table.type == "inflamable") then
                table.insert(to_add, copy_table(blocks.inflamable))
            elseif (tmp_table.type == "tnt") then
                table.insert(to_add, copy_table(blocks.tnt))
            elseif (tmp_table.type == "electric_box") then
                table.insert(to_add, copy_table(blocks.electric_box))
            elseif (tmp_table.type == "waterbomb") then
                table.insert(to_add, copy_table(blocks.waterbomb))
            elseif (tmp_table.type == "chest") then
                table.insert(to_add, copy_table(blocks.chest))
            else
                table.insert(to_add, copy_table(blocks.floor))
            end
            to_add[x].state = tmp_table.state
            to_add[x].frame = tmp_table.frame
        end
        table.insert(map, to_add)
    end
    return map
end