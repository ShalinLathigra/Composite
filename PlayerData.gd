extends Node

onready var player = preload("res://Components/Player/Player.tscn").instance()
onready var leaders = []
onready var spare_units = []

onready var target = null

func _ready():
	for _i in range (25):
		var unit = GLOBAL.unit_scenes[randi() % 4].instance()
		unit.friendly = true
		spare_units.push_back(unit)

#	At start of game, no leaders or units
#	As play continues, add more leaders/take away units.

func get_leader(index : int) -> Unit:
	if (leaders.size() > index):
		return leaders[index]
	return null

func set_leads_spawn_positions() -> void:
	for i in range (leaders.size()):
		var l_offset_angle = 180.0 - 90.0 * i
		var l_offset = Vector2(cos(deg2rad(l_offset_angle)), sin(deg2rad(l_offset_angle)))
		
		var l : Unit = leaders[i]
		l.position = player.position + l_offset * 128.0
		
		for j in range(l.get_followers().size()):
			var f_offset_angle = 90.0 + 360.0 / 10.0 * (j - l.get_followers().size() * 0.5)
			var f_offset = Vector2(cos(deg2rad(f_offset_angle)), sin(deg2rad(f_offset_angle)))
		
			var f : Unit = l.get_followers()[j]
			if (f.get_parent()):
				f.get_parent().remove_child(f)
			f.position = l.position + f_offset * 64.0
