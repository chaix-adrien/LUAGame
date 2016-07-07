function recur_copy_table(tab)
    local copy = {}
    for rank, value in pairs(tab) do
        if (type(value) == "table") then
            copy[rank] = recur_copy_table(value)
        else
            copy[rank] = value
        end
    end
    return (copy)
end

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
    io.close(file)
    return map
end

function indent_write(to_write, depth, indent_width)
    for i = 1, (depth * indent_width), 1 do
        io.write(" ")
    end
    io.write(to_write)
end

function show_table(table, depth)
    for rank, value in pairs(table) do
        if (type(value) == "table") then
            show_table(value, depth + 1)
        elseif (type(value) ~= "function" and type(value) ~= "userdata") then
            indent_write(rank .. " : " .. value, depth, 3)
        end
    end
end

function table_len(tab)
    if (type(tab) ~= "table") then
        return (0)
    end
    local ret = 0
    for rnk, val in pairs(tab) do
        if (type(val) ~= "userdata" and type(val) ~= "function") then
            ret = ret + 1
        end
    end 
    return (ret)
end

function export_table(obj, depth)
    for rnk, val in pairs(obj) do
        local tmp_type = type(val)
        if (tmp_type ~= "function" and tmp_type ~= "table" and tmp_type ~= "userdata") then
            local tmp = {rank = rnk, value = val}
            indent_write(JSON:encode(tmp) .. "\n", depth, 3)
        elseif (tmp_type == "table" and table_len(val) > 0) then
            indent_write("table\n", depth, 3)
            indent_write(rnk .. "\n", depth, 3)            
            export_table(val, depth + 1)
            indent_write("end_table\n", depth, 3)
        end
    end
end

function export_list(list, filename, listname)
    local file = io.open(filename, "w+")
    io.output(file)
    io.write(listname .. "\n")
    export_table(list, 0)
    io.write("end_table")
    io.output(io.stdout)
    io.close(file)
end

function import_table()
    local out = {}
    out["tab_name"] = io.read()
    if (out["tab_name"] == nil) then
        return nil
    end
    repeat
        local tmp = io.read()
        if (tmp == nil) then
            return nil
        else
            tmp, trash = tmp:gsub(" ", "")
        end
        if (tmp == "table") then
            local tmp_tab = import_table(file)
            out[tmp_tab.tab_name] = tmp_tab
            tmp_tab.tab_name = nil
        elseif (tmp ~= "end_table") then
            local tab = JSON:decode(tmp)
            out[tab.rank] = tab.value
        end
    until (tmp == "end_table")
    return (out)
end

function import_list(filename)
    local file = io.open(filename, "r")
    if (file == nil) then return nil end
    io.input(file)
    local out = import_table()
    io.input(io.stdin)
    io.close(file)
    out.tab_name = nil
    return (out)
end