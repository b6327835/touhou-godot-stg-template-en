extends BulletSpawnerBomb

func _on_ready():
	print("[BOMB SPAWNER] Configured - Type:", spawn_bullet_type, ", Color:", spawn_bullet_color)
	#print("[BOMB SPAWNER] Way num:", way_num, ", Way range:", way_range, ", Way rotation:", way_rotation)
	#
	## Verify the bullet type exists
	#if spawn_bullet_type in RS.bullet_pics:
		#print("[BOMB SPAWNER] Available colors for", spawn_bullet_type, ":", RS.bullet_pics[spawn_bullet_type].size())
	#else:
		#print("[BOMB SPAWNER ERROR] Bullet type", spawn_bullet_type, "not found!")

func bullet_spawn_logic():
	var bullets = get_bullet_group(way_num)
	set_way_bullet_spawn(bullets)
	spawn_group_of_bullet(bullets)
	
	# Rotate the pattern each time for a nice spiral effect
	way_rotation += 15
	
	# Cycle through different colors for visual effect
	if spawn_bullet_color < 15:
		spawn_bullet_color += 1
	else:
		spawn_bullet_color = 0
