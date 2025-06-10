extends Node2D

@export var keep_time = 10
@export var bomb_name = "默认炸弹发弹点"
signal bomb_out

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
	#print("[BOMB] Activating bomb - enabling spawner and starting timer")
	
	if not has_node(bomb_name):
		print("[BOMB ERROR] Cannot find bomb spawner node:", bomb_name)
		return
	
	var bomb_spawner = get_node(bomb_name)
	if bomb_spawner == null:
		print("[BOMB ERROR] Bomb spawner is null")
		return
		
	bomb_spawner.enable = true
	bomb_spawner.enable_shoot_bullet = true
	bomb_spawner.shoot()
	$Timer.start()

func _on_Timer_timeout():
	#print("[BOMB] Bomb time expired - disabling spawner")
	
	if not has_node(bomb_name):
		print("[BOMB ERROR] Cannot find bomb spawner node for cleanup:", bomb_name)
		return
		
	var bomb_spawner = get_node(bomb_name)
	if bomb_spawner == null:
		print("[BOMB ERROR] Bomb spawner is null during cleanup")
		return
		
	bomb_spawner.enable = false
	bomb_spawner.enable_shoot_bullet = false
	bomb_spawner.stop_shoot()
	emit_signal("bomb_out")
