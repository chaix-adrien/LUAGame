function nil_func()
	return nil
end



function update_mob_frame_loop(mob, dt)
	mob.frame = mob.frame + 2 * frame_speed * mob.state.loop_frame
	if (mob.frame > table.getn(mob.sprite) or mob.frame <= 1) then
		mob.state.loop_frame = -mob.state.loop_frame
	end
	if (mob.frame > table.getn(mob.sprite)) then
		mob.frame = table.getn(mob.sprite)
	end
	if (mob.frame < 1) then
		mob.frame = 1
	end
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
	deal_dammages(player, 20, 1)
end

function draw_mob_loop(mob, focus)
	px, py = map_to_pix(mob.pos.x, mob.pos.y, focus)
	px, py = rotate_pos(px, py, mob.r, mob.sprite[math.floor(mob.frame)])
	if (mob.color) then
		love.graphics.setColor(mob.color)
	end
	love.graphics.draw(mob.sprite[math.floor(mob.frame)], px, py, mob.r, mob.scale.x, mob.scale.y)
	love.graphics.setColor(255, 255, 255, 255)
end

function draw_mob_basic(mob, focus)
	px, py = map_to_pix(mob.pos.x, mob.pos.y, focus)
	px, py = rotate_pos(px, py, mob.r, mob.sprite[math.floor(mob.frame)])
	if (mob.color) then
		love.graphics.setColor(mob.color)
	end
	love.graphics.draw(mob.sprite[math.floor(mob.frame)], px, py, mob.r, mob.scale.x, mob.scale.y)
	love.graphics.setColor(255, 255, 255, 255)
end

function deal_20_damage(player, mob, i, j)
	deal_dammages(mob, 20)
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
	update_mob_only_frame(mob, dt)
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
	update_mob_only_frame(mob, dt)
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
	update_mob_only_frame(mob, dt)
end

function move_turret_target_mobile(mob, dt)
	if (mob.state.mode == 1) then
		maze(mob)
		mob.frame = (mob.frame + dt * 3) % (#mob.sprite + 1)
		if (mob.frame <= 1) then mob.frame = 2 end
		--mob.pos.x, mob.pos.y = move_of(mob.pos, {x = mob.target.pos_x - mob.pos.x, y = mob.target.pos_y - mob.pos.y}, 0.05)
	else
		mob.frame = 1
	end
end

function update_turret_target_mobile(mob, dt)
	mob.state.fire_time = mob.state.fire_time + dt
	if (mob.state.fire_time >= mob.state.fire_frequency and mob.state.mode_time > 1 and mob.state.mode_time < mob.state.turret_time - 1) then
		shoot(mob.pos, mob.r, 10)
		mob.state.fire_time = 0
	end
	if (mob.target ~= nil and mob.state.fire_time < mob.state.fire_frequency - 0.2) then
		local r = vec_to_r(mob.target.pos_x - mob.pos.x, mob.target.pos_y - mob.pos.y) -- TODO : rotate etrange
		mob.r = mob.r + ((r - mob.r) / 10)
	end
	if (mob.state.mode == 0 and mob.state.mode_time >= mob.state.turret_time) then mob.state.mode = 1
	elseif (mob.state.mode_time < 1) then mob.state.mode = 0
	end
	mob.state.mode_time = (mob.state.mode_time + dt) % mob.state.cycle_time
end