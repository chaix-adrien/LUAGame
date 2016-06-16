function move_mob_fix(mob, dt)
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