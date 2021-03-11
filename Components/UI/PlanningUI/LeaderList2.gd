extends UnitList
class_name LeadList

signal emptied (obj)
func _on_Area2D_input_event(viewport, event, shape_idx):
	._on_Area2D_input_event(viewport, event, shape_idx)

func _on_Area2D_mouse_entered():
	if (enabled):
		$UnitList/Sprite5.material.set_shader_param("active", 1.0);
	active = true

func _on_Area2D_mouse_exited():
	if (enabled):
		$UnitList/Sprite5.material.set_shader_param("active", 0.0);
	active = false

func clear():
	clear_list()
	$UnitList2.clear_list()
	pass

func connect_func(s : String, l : Node, f : String) -> void:
	connect (s, l, f)
	
func connect_select_func(l : Node, f : String) -> void:
	.connect_select_func(l, f)
	$UnitList2.connect_select_func(l, f)
func connect_drop_func(l : Node, f : String):
	.connect_drop_func(l, f)
	$UnitList2.connect_drop_func(l, f)
	

func set_active(a : bool) -> void:
	enabled = a
	if not enabled:
		$UnitList/Sprite5.material.set_shader_param("active", 0.15);
	elif active:
		$UnitList/Sprite5.material.set_shader_param("active", 1.0);
	else:
		$UnitList/Sprite5.material.set_shader_param("active", 0.0);

func populate_with(source : Unit):
	var f = source.clear_followers()
	unit_list.push_back(source)
	$UnitList2.set_unit_array(f)

func get_followers() -> Array:
	return $UnitList2.unit_list
	
func update_list() -> void:
	.update_list() 
	$UnitList2.set_active(is_full())
