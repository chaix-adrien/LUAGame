function nil_func()
	return nil
end

function update_mob_only_frame(mob, dt)
	mob.frame = mob.frame + 2 * frame_speed
	if (mob.frame > #mob.sprite) then
		mob.frame = 1
	end
end


function move_mob_rand(mob)
	mob.pos.x = mob.pos.x + math.random() * 0.1
	mob.pos.y = mob.pos.y + math.random() * 0.1
	-- TODO true rand verifier pos until
end

function walk_mob_hit(player, mob)
	player.life = player.life - 20
	player.no_hit = 1
end

function draw_mob_basic(mob)
	px, py = map_to_pixel(mob.pos.x, mob.pos.y)
	px, py = rotate_pos(px, py, mob.r, mob.sprite[math.floor(mob.frame)])
	love.graphics.draw(mob.sprite[math.floor(mob.frame)], px, py, mob.r, mob.scale.x, mob.scale.y)
end

function kill_mob(player, mob, i, j)
	table.remove(mobs[i], j)
end

function update_turret_fix(mob, dt)
	mob.state.fire_time = mob.state.fire_time + dt
	if (mob.state.fire_time >= mob.state.fire_frequency) then
		fire(mob.pos, mob.r, 10)
		mob.state.fire_time = 0
	end
end

function update_turret_rot(mob, dt)
	mob.state.fire_time = mob.state.fire_time + dt
	if (mob.state.fire_time >= mob.state.fire_frequency) then
		shoot(mob.pos, mob.r, 10)
		mob.state.fire_time = 0
	end
	if (mob.state.fire_time < mob.state.fire_frequency - 0.8) then
		mob.r = mob.r + dt * mob.state.side 	
	end
	if (mob.r > mob.state.max_rot or mob.r < mob.state.min_rot) then
		mob.state.side = mob.state.side * -1
	end
end

function update_turret_target(mob, dt)
	mob.state.fire_time = mob.state.fire_time + dt
	if (mob.state.fire_time >= mob.state.fire_frequency) then
		shoot(mob.pos, mob.r, 10)
		mob.state.fire_time = 0
	end
	if (mob.target ~= nil and mob.state.fire_time < mob.state.fire_frequency - 0.8) then
		local r = vec_to_r(mob.target.pos_x - mob.pos.x, mob.target.pos_y - mob.pos.y)
		mob.r = mob.r + ((r - mob.r) / 10)
	end
end