class_name BulletSpawnerBomb
extends BulletSpawner

func _on_ready():
	bullet_manager_name = "BombBulletLayer"

# Override the remove_spawner method to prevent bomb spawners from being auto-removed
func remove_spawner():
	# Bomb spawners should not be removed automatically
	# They need to persist for reuse
	pass

# Override self_free to prevent accidental removal of bomb spawners
func self_free():
	# Bomb spawners should not free themselves
	# Only remove from bullet spawners list but don't queue_free
	STGSYS.bullet_spawners.erase(self)

#func bullet_spawn_logic():
#	var bullets = get_bullet_group(way_num)
#	set_way_bullet_spawn(bullets)
#	spawn_group_of_bullet(bullets)
