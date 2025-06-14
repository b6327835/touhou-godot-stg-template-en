@tool
class_name SpellCard
extends Node

@export var spell_card_res:SpellCardRes:
	set(scr):
		spell_card_res = scr
		if scr != null:
			keep_sec = scr.keep_sec
			spellcard_name = scr.spellcard_name

@export var keep_sec = 60.0
@export var spellcard_name := ""

@onready var FUI = get_node("/root/TouhouDanmakuTemplate/UI")

var running = false
var spawners = []
var shades = []
var reflectors = []

var last_left_time = 0
var frames = 0

var this_second_runed = false

signal spell_finish(spell)

func _enter_tree():
	if !Engine.is_editor_hint():
		get_node("测试背景").free()

func _ready():
	$Timer.wait_time = keep_sec
	for spawner in get_node("符卡发弹点").get_children():
		if spawner is Marker2D:
			spawners.append(spawner)
		else:
			spawners.append_array(spawner.get_children())
	for shade in get_node("符卡遮罩").get_children():
		if shade is Area2D:
			shades.append(shade)
		else:
			shades.append_array(shade.get_children())
	for reflect in get_node("符卡反射板").get_children():
		if reflect is Area2D:
			reflectors.append(reflect)
		else:
			reflectors.append_array(reflect.get_children())

func add_spawner(spawner,node_name=null):
	if node_name == null:
		$"符卡发弹点".add_child(spawner)
		spawners.append(spawner)
	else:
		pass
		#$"符卡发弹点".get_node(node_name).add_child(spawner)

func _process(delta):
	if running:
		_card_running_event()
		STGSYS.time_left = get_left_time()
		if last_left_time != floori(get_left_time()):
			this_second_runed = false
		last_left_time = floori(get_left_time())
		frames+=1

func _set_spell_card_time(sec):
	if Engine.is_editor_hint():
		$Timer.wait_time = sec
		keep_sec = sec

func run_spell_card():
	_before_card_run()
	FUI.setSpellCardName(spellcard_name)
	print("spellcard_name: %s" % spellcard_name)
	if spellcard_name!="":
		FUI.play_SCN_anim()
	running = true
	STGSYS.time_left = keep_sec
	$Timer.start()

func _card_running_event():
	var left_time = floor(get_left_time())
	var running_time = floor(get_card_run_time())

func _before_card_run():
	pass

func _after_card_run():
	pass

func get_left_time():
	#获取当前剩余时间
	return $Timer.time_left

func get_card_run_time():
	#获取当前符卡运行的时间
	return $Timer.wait_time - $Timer.time_left

func get_shades(sd_name):
	for shade in shades:
		if shade.name == sd_name:
			return shade

func get_reflector(rf_name):
	for rf in reflectors:
		if rf.name == rf_name:
			return rf

func get_spawner(spawner_name):
	for spawner in spawners:
		if spawner.name == spawner_name:
			return spawner

func free_all():
	emit_signal("spell_finish",self)
	var obj = []
	obj.append_array(spawners)
	obj.append_array(shades)
	obj.append_array(reflectors)
	for o in obj:
		if is_instance_valid(o):
			o.self_free()

func stop_card():
	$Timer.stop()
	running = false
	FUI.setSpellCardName("")
	_after_card_run()
	free_all()

func _on_Timer_timeout():
	running = false
	FUI.setSpellCardName("")
	_after_card_run()
	free_all()
