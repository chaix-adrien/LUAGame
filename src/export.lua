function export_map(filename)
    file = io.open(filename, "w+")
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