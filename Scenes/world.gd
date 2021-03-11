extends Node2D

var planning = true

var p_node : Node2D
var l_node : Node2D

func _ready():
	l_node = GLOBAL.level_scene.instance()
	add_child(l_node)
	
	# Need to instance both nodes, set one to off.
	var player : Player = PlayerData.player
	add_child(player)
	
	p_node = GLOBAL.planning_scene.instance()
	set_stage()
	
func advance_stage():
	planning = not planning
	set_stage()
	
func set_stage():
	var cam : ShakyCamera = get_node(GLOBAL.camera)
	cam.global_position = Vector2(0,0)
	cam.set_active(!planning)
	if (planning):
		add_child(p_node)
	else:
		remove_child(p_node)
	p_node.set_active(planning)
	l_node.set_active(!planning)
	
	var p : Player = get_node(GLOBAL.player)
	p.global_position = Vector2(0,0)
	p.set_active(!planning)
	
