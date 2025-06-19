extends Node2D

@export var keep_time = 3
@export var bomb_name = "默认炸弹发弹点"
signal bomb_out

#var bomb_use_count = 0  # Track bomb usage for debugging

func _ready():
	$Timer.wait_time = keep_time
	#print("[BOMB] Bomb ready with spawner name:", bomb_name)
	
	# Verify the spawner node exists
	#if has_node(bomb_name):
		#print("[BOMB] Found bomb spawner node")
	#else:
		#print("[BOMB ERROR] Cannot find bomb spawner node:", bomb_name)

func _process(delta):
	pass

func run_bomb():
	#bomb_use_count += 1
	#print("[BOMB] Activating bomb #", bomb_use_count, ")
	
	if not has_node(bomb_name):
		#print("[BOMB ERROR] Cannot find bomb spawner node:", bomb_name)
		return
	
	var bomb_spawner = get_node(bomb_name)
	if bomb_spawner == null:
		#print("[BOMB ERROR] Bomb spawner is null")
		return
		
	#print("[BOMB] Before activation - enable:", bomb_spawner.enable, " shooting:", bomb_spawner.enable_shoot_bullet)
	
	bomb_spawner.enable = true
	bomb_spawner.enable_shoot_bullet = true
	bomb_spawner.shoot()
	
	# Force immediate bullet spawn for instant bomb effect
	bomb_spawner.bullet_spawn_logic()
	
	$Timer.start()
	
	#print("[BOMB] After activation - enable:", bomb_spawner.enable, " shooting:", bomb_spawner.enable_shoot_bullet)

func _on_Timer_timeout():
	#print("[BOMB] Bomb #", bomb_use_count, " time expired - disabling spawner")
	
	if not has_node(bomb_name):
		#print("[BOMB ERROR] Cannot find bomb spawner node for cleanup:", bomb_name)
		return
		
	var bomb_spawner = get_node(bomb_name)
	if bomb_spawner == null:
		#print("[BOMB ERROR] Bomb spawner is null during cleanup")
		return
		
	#print("[BOMB] Before cleanup - enable:", bomb_spawner.enable, " shooting:", bomb_spawner.enable_shoot_bullet)
	
	# stop the bomb spawner
	bomb_spawner.stop_shoot()
	bomb_spawner.enable = false
	bomb_spawner.enable_shoot_bullet = false
	
	# Prevent bomb spawner from being auto-removed
	bomb_spawner.need_remove = false
	
	# Reset the spawner state
	bomb_spawner.first_run = true
	bomb_spawner.frame = 0
	bomb_spawner.start_timer_counted = false
	
	#print("[BOMB] After cleanup - enable:", bomb_spawner.enable, " shooting:", bomb_spawner.enable_shoot_bullet, " first_run:", bomb_spawner.first_run)
	
	# Reset the bomb running flag
	STGSYS.bomb_running = false
	
	emit_signal("bomb_out")
