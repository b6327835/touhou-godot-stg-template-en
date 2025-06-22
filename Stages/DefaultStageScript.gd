extends Node2D

func _process(delta):
	#print(get_tree().get_nodes_in_group("bullet").size())
	pass

func _enter_tree():
	STGSYS.current_level = self

func _ready():
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST	#get_node("SpellCard/范例：波与粒的境界").run_spell_card()
	#get_node("SpellCard/Square：WavingFormation").run_spell_card()
	#get_node("SpellCard/Prism：HeavenEarthPrism").run_spell_card()
	#get_node("SpellCard/方阵：完美立方体").run_spell_card()
	#get_node("SpellCard/SquareNon1").run_spell_card()
	#get_node("SpellCard/SquareNon2").run_spell_card()
