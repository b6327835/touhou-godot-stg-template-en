class_name SelfFlyer
extends CharacterBody2D
#一个基础的自机
#ColorRect可替换成Sprite2D图

#const MIN_MOVE_DISTANCE = 40
const DEFAULTSELFPOSITION = Vector2(240,480)
@export var damage = 1
@export var move_speed = 4.0
@export var low_speed_speed = 2
@export var unbreakable = false
@export var bomb_name = "DefaultBomb"
var svelocity = Vector2.ZERO
var unbreakable_anim_time = 2.0
var unbreakable_bomb_time = 1.0
var bullet_group = "player_bullet"

func _ready():
	# Set high priority for responsive input processing
	set_process_priority(99)  # Very high priority for player input
	
	$UnbreakableBombTimer.wait_time = unbreakable_bomb_time #设置炸弹无敌时间
	$UnbreakableAnimTimer.wait_time = unbreakable_anim_time #设置动画无敌时间
	STGSYS.set_player(self)
	STGSYS.connect("use_bomb",Callable(self,"bomb_use"))
	STGSYS.self_flyers.append(self)
	
	for node in $Shooter.get_children():
		node.add_bullet_group(bullet_group)
	
	#print("[PLAYER] Player ready - bomb system connected")

func _input(event):
	# IMMEDIATE invincibility activation
	if Input.is_action_just_pressed("bomb") and not unbreakable:
		if STGSYS.bomb > 0 and not STGSYS.bomb_running:

			unbreakable = true
			#print("[PLAYER] EMERGENCY invincibility activated")

func _on_hit_by(obj):	#自机被击中时调用的方法
	#obj代表击中自机的对象
	if !unbreakable:
		STGSYS.decrease_life()
		if STGSYS.life <= 0:
			STGSYS.emit_signal("game_over")
		position = DEFAULTSELFPOSITION
		unbreakable = true
		$UnbreakableAnimTimer.start()
		$AnimationPlayer.play("HitEffect")

func bomb_use():
	#使用炸弹时开启无敌
	unbreakable = true
	$UnbreakableBombTimer.wait_time = $Bombs.get_node(bomb_name).keep_time + \
	unbreakable_bomb_time
	$UnbreakableBombTimer.start()
	$Bombs.get_node(bomb_name).run_bomb()
	
	#print("[PLAYER] Bomb activated - invincibility: ", unbreakable)

func get_collision_shape():
	return $CollectArea.shape

func get_dead_point():
	return $DeadPoint

func _physics_process(delta):
	move(delta)
	
	#玩家射击状态判断与切换
	if STGSYS.shooting:
		shoot()
	else:
		unshoot()

func unshoot():
	#禁用玩家射击（禁用所有发弹点就行）
	for shooter in $Shooter.get_children():
		shooter.enable_shoot_bullet = false

func shoot():
	#启用玩家射击状态
	var power = STGSYS.power
	#判断火力，不同火力阶段开启不同数量的发弹点
	if power >= 0:
		$"Shooter/PlayerBulletSpawner2".enable_shoot_bullet = true
	if power >= 60:
		$"Shooter/PlayerBulletSpawner".enable_shoot_bullet = true
	if power >= 120:
		$"Shooter/PlayerBulletSpawner3".enable_shoot_bullet = true

func move(delta): 
	#用于处理玩家移动的动作
	var vector = STGSYS.selfMoveVector
	var speed
	
	if STGSYS.lowSpeedMode:
		speed = low_speed_speed
	else:
		speed = move_speed
		
	if vector != Vector2.ZERO:
		svelocity = vector * speed
	else:
		svelocity = Vector2.ZERO
#		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
	move_and_collide(svelocity)
	
	position.x = clamp(position.x, 0 + abs($Borders/UPLeft.position.x), STGSYS.view_portsize.x - abs($Borders/DownRight.position.x))
	position.y = clamp(position.y, 0 + abs($Borders/UPLeft.position.y), STGSYS.view_portsize.y - abs($Borders/DownRight.position.y))


func _on_UnbreakableAnimTimer_timeout():
	#在死亡无敌动画结束后降低玩家血量以及检测剩余血量
	$AnimationPlayer.stop()
	unbreakable = false

func _on_UnbreakableBombTimer_timeout():
	#炸弹无敌时间结束后
	unbreakable = false

func _on_SelfFlyer_graze():
	STGSYS.change_value("graze",STGSYS.graze+1)
	STGSYS.change_value("score",STGSYS.score+5)
