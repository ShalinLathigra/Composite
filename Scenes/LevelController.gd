extends Node2D

onready var active : bool = false

var allies : Array
var enemies : Array
var ally_spawners : Array
var enemy_spawners : Array

func _init():
	allies = []
	enemies = []
	ally_spawners = []
	enemy_spawners = []

onready var num_enemies : int = 0
onready var max_enemies : int = 30
onready var min_enemies : int = 15
onready var spawners_active : bool = false

func add_unit(unit : Unit, friendly : bool = true, active : bool = true) -> void:
	if unit.get_parent():
		return
	var group = $Enemies
	if friendly:
		group = $Allies
	group.add_child(unit)
	unit.set_active(active)

func register_unit(unit : NodePath, friendly : bool = true) -> void:
	if (friendly):
		allies.push_back(unit)
	else:
		enemies.push_back(unit)
		if (spawners_active):
			num_enemies += 1
			if (num_enemies >= max_enemies):
				toggle_spawners(friendly, false)
			
func unregister_unit(unit : NodePath, friendly : bool = true) -> void:
	if (friendly and allies.find(unit) >= 0):
		allies.remove(allies.find(unit))
	elif !friendly and enemies.find(unit) >= 0:
		if (spawners_active):
			num_enemies -= 1
			if (num_enemies < min_enemies):
				toggle_spawners(friendly, true)	
		enemies.remove(enemies.find(unit))

func get_nearest(pos : Vector2, friendly : bool = true):
	var targets = null
	if (friendly):
		targets = enemies
	else:
		targets = allies
	var nearest = null
	if (len(targets) > 0 and active):
		nearest = GLOBAL.player
		var nearest_dist = -1
		for target in targets:	
			if (get_node(target)):
				var curr = (get_node(target).global_position - pos).length_squared()
				if curr < nearest_dist or nearest_dist == -1:
					nearest = target
					nearest_dist = curr
			else:
				targets.remove(targets.find(target))
			
	if (nearest):	
		print("success! nearest = %s" % nearest)
	return nearest
	
	# Spawner Logic

func register_spawner(spawner : NodePath, friendly : bool = false) -> void:
	if (friendly):
		ally_spawners.push_back(spawner)
	else:
		enemy_spawners.push_back(spawner)# I just think it's a good idea to have access to this lol
		
func toggle_spawners(friendly : bool = false, active : bool = false):
	var spawners = enemy_spawners
	if (friendly):
		spawners = ally_spawners
		
	for spawner in spawners:
		get_node(spawner).set_active(active)

# General Use
onready var time_factor = 1.0

var selected_leader = null

func _unhandled_key_input(event):
	if (active):
		if (Input.is_action_just_pressed("debug_reset")):
			get_node(GLOBAL.world).advance_stage()
			spawners_active = false
		if (Input.is_action_just_pressed("debug_start")):
			spawners_active = true
			toggle_spawners(false, spawners_active) 
		if (Input.is_action_just_pressed("player_slow_time")):
			GLOBAL.level_active = false
			$Tween.stop(self, "time_factor")
			$Tween.interpolate_property(self, "time_factor", 1.0, 0.0, 0.5, Tween.TRANS_LINEAR)
			$Tween.start()
		if (Input.is_action_just_released("player_slow_time")):
			GLOBAL.level_active = true
			$Tween.stop(self, "time_factor")
			$Tween.interpolate_property(self, "time_factor", 0.0, 1.0, 0.5, Tween.TRANS_LINEAR)
			$Tween.start()
			
		if (event is InputEventKey and not GLOBAL.level_active):
			if (event.scancode == KEY_1 and event.is_pressed()):
				set_selected_leader(PlayerData.get_leader(0))
			if (event.scancode == KEY_2 and event.is_pressed()):
				set_selected_leader(PlayerData.get_leader(1))
			if (event.scancode == KEY_3 and event.is_pressed()):
				set_selected_leader(PlayerData.get_leader(2))
		
func set_selected_leader(unit : Unit) -> void:
	if not unit:
		return
	if (selected_leader):
		selected_leader.set_selected(0.0)
	selected_leader = unit
	selected_leader.set_selected(1.0)

	
func set_active(a : bool):
	active = a
	$HelpMenu.set_active(a)
	GLOBAL.time_factor = 1.0
	
	# Clear existing units
	for n in $Enemies.get_children():
		n.set_active(false)
		unregister_unit(n.get_path(), false)
		$Enemies.remove_child(n)
		n.queue_free()
	for n in $Allies.get_children():
		n.set_active(false)
		unregister_unit(n.get_path())
		$Allies.remove_child(n)
		
	toggle_spawners(false, false)
	toggle_spawners(true, false)
	
	# Populate Player Units
	PlayerData.player.global_position = Vector2(0,0)
	for lead in PlayerData.leaders:
		add_unit(lead)
		for foll in lead.get_followers():
			add_unit(foll)
	if (selected_leader):
		selected_leader.set_selected(0.0)


func _on_Tween_tween_step(object, key, elapsed, value):
	GLOBAL.time_factor = time_factor


func _on_Tween_tween_completed(object, key):
	if (GLOBAL.time_factor == 1.0 and selected_leader):
		selected_leader.set_selected(0.0)
