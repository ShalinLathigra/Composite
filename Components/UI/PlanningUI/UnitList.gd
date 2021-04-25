extends Position2D
class_name UnitList

onready var unit_list : Array = []
export (int) var dim_x = 5
export (int) var max_size = 25

export (bool) var enabled = false

export (Vector2) var unit_dims = Vector2(64, 64)

func add_unit(u : Unit) -> void:
	unit_list.push_back(u)
	u.set_active(false)
	u.visible = false
	
	if not u in get_children():
		add_child(u)
	
func set_unit_array(u_arr : Array) -> void:
	unit_list.clear()
	for u in u_arr:
		add_unit(u)
	
func is_full() -> bool:
	return unit_list.size() >= max_size

func is_empty() -> bool:
	return unit_list.size() == 0

func clear_list():
	for unit in unit_list:
		if (unit in get_children()):
			remove_child(unit)
	unit_list.clear()

func update_list() -> void:
	for i in range(unit_list.size()):
		var unit : Node = unit_list[i]
		unit.global_position = global_position + Vector2((i % dim_x) * unit_dims.x, (i / dim_x) * unit_dims.y)
		unit.visible = true

func get_unit_at_mouse() -> Unit:
	var to_mouse = get_global_mouse_position() - global_position
	var i : int = stepify(to_mouse.x, unit_dims.x) / unit_dims.x
	var j : int = stepify(to_mouse.y, unit_dims.y) / unit_dims.y
	
	var index : int = i + j * dim_x
	
	if index < unit_list.size() and index >= 0:
		var ret = unit_list[index]
		if (ret.get_parent()):
			ret.get_parent().remove_child(ret)
		unit_list.remove(index)
		ret.position = Vector2(0,0)
		ret.global_position = Vector2(0,0)
		return ret
		
	return null

# Unit Selection
onready var active : bool = false
func _ready():
	set_active(enabled)

func set_active(a : bool) -> void:
	enabled = a
	if (!enabled):
		$Sprite5.material.set_shader_param("active", 0.15);
	elif active:
		$Sprite5.material.set_shader_param("active", 1.0);
	else:
		$Sprite5.material.set_shader_param("active", 0.0);
	update_list()

func _on_Area2D_mouse_entered():
	if (enabled):
		$Sprite5.material.set_shader_param("active", 1.0);
	active = true

func _on_Area2D_mouse_exited():
	if (enabled):
		$Sprite5.material.set_shader_param("active", 0.0);
	active = false


signal unit_selected (src, unit)
signal unit_dropped (src)

func connect_func(s : String, l : Node, f : String) -> void:
	connect(s, l, f)

func connect_select_func(l : Node, f : String) -> void:
	connect("unit_selected", l, f)
func connect_drop_func(l : Node, f : String):
	connect("unit_dropped", l, f)
	
func _on_Area2D_input_event(_viewport, event, shape_idx):
	if (event is InputEventMouseButton and enabled):
		if (active):
			if (event.button_index == BUTTON_LEFT and event.is_pressed()):
				# Remove unit from this one now
				emit_signal("unit_selected", self, get_unit_at_mouse())
				update_list()
			if (event.button_index == BUTTON_LEFT and !event.pressed):
				emit_signal("unit_dropped", self)
				update_list()
