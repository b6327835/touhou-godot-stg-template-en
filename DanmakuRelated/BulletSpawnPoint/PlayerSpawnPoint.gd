extends BulletSpawner

func _on_ready():
	bullet_manager_name = "PlayerBulletLayer"
	spawn_bullet_type = "StarBullet"
	spawn_bullet_owner = "self"
	spawn_bullet_color = 9
	way_rotation = -180
	
	bullet_scale = Vector2(1.0, 1.0)
	
	# Debug visualization to help locate the spawner
	if not has_node("DebugSprite"):
		var debug_sprite = ColorRect.new()
		debug_sprite.name = "DebugSprite"
		debug_sprite.color = Color(0, 0, 1, 0.3)
		debug_sprite.size = Vector2(8, 8)
		debug_sprite.position = Vector2(-4, -4)
		add_child(debug_sprite)
	
	#print("[PLAYER SPAWNER] Configured - Type:", spawn_bullet_type, ", Color:", spawn_bullet_color)
	
	# Verify the bullet type exists
	if spawn_bullet_type in RS.bullet_pics:
		print("[PLAYER SPAWNER] Available colors for", spawn_bullet_type, ":", RS.bullet_pics[spawn_bullet_type].size())
	else:
		print("[PLAYER SPAWNER ERROR] Bullet type", spawn_bullet_type, "not found!")

func bullet_spawn_logic():
	var bullets = get_bullet_group(way_num)
	set_way_bullet_spawn(bullets)
	spawn_group_of_bullet(bullets)
