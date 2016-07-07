function is_walkable(px, py)
	local x = math.floor(px)
	local y = math.floor(py)
	if (x >= 1 and x <= x_fields and y >= 1 and y <= y_fields and map[y][x].walkable == 1) then
		return 1
	else
		return 0
	end
end

function zombie_turn_check_side(mob, side)
	if (mob.state.move[side] ~= 0) then
		if (mob.pos[side] % 1 > mob.state.intersec - 0.1 and mob.pos[side] % 1 < mob.state.intersec + 0.1) then
			return 1
		end	
	end
	return 0 
end

function move_zombie_turn_last(mob, dt)
	local m = {x = 0, y = 0}
	local v = frame_speed / 4
	m.x = mob.pos.x + mob.state.move.x
	m.y = mob.pos.y + mob.state.move.y
	if (is_walkable(m.x, m.y) == 0 and (zombie_turn_check_side(mob, "x") == 1 or zombie_turn_check_side(mob, "y") == 1)) then
		local reapeted = 0
		repeat
			mob.state.move.x = (math.random(3) - 2)
			mob.state.move.y = (math.random(3) - 2)
			if (math.abs(mob.state.move.x + mob.state.move.y) ~= 1) then
				mob.state.move.x = 0
			end
			if (mob.state.move.x + mob.state.move.y == 0) then
				mob.state.move.x = 1
			end
			m.x = mob.pos.x + mob.state.move.x
			m.y = mob.pos.y + mob.state.move.y
			reapeted = reapeted + 1
		until (is_walkable(m.x, m.y) == 1 or reapeted > 40)
		
		-- changer direction 
	end
	mob.pos.x, mob.pos.y = move_of(mob.pos, mob.state.move, v, 0)
end

function update_zombie_turn_last(mob, dt)

end

function update_zombie_turn_last(mob, dt)

end