extends BulletSpawner

func _on_ready():
	bullet_manager_name = "PlayerBulletLayer"
	spawn_bullet_type = "SmallBullet"
	spawn_bullet_owner = "self"
	way_rotation = -180

func bullet_spawn_logic():
	var bullets = get_bullet_group(way_num)
	set_way_bullet_spawn(bullets)
	spawn_group_of_bullet(bullets)
