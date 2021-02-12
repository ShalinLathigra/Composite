extends Node


enum {
	IDLE, 	# Do Nothing, check if state should change
	WALK, 	# Move at slow speed
	RUN, 	# Move at fast speed
	CHASE,	# Move at speed towards target
	SHOOT, 	# Stop moving, fire long range attack
	HIT, 	# Stop moving, make short range attack
	HURT, 	# Stop moving, receive hit
	DODGE, 	# Keep moving, can't receive hit
	DIE		# Stop everything, die
	}
	
enum BULLETS {
	BASE,
	ROCKET
}
enum PICKUPS {
	AMMO,
	SHIELD,
}
const bullets = {
	BULLETS.BASE : preload("res://Components/Projectiles/Instanceable/Bullet.tscn"),
	BULLETS.ROCKET : preload("res://Components/Projectiles/Instanceable/Rocket.tscn")
	}
	
const ally_frames = preload("res://Components/Units/Spriteframes/AllyFrames.tres")
const enemy_frames = preload("res://Components/Units/Spriteframes/EnemyFrames.tres")

const pickups = {
	PICKUPS.AMMO : preload("res://Components/PickUps/Instanceable/AmmoPickUp.tscn"),
	PICKUPS.SHIELD : preload("res://Components/PickUps/Instanceable/ShieldPickUp.tscn"),
}

var player = "/root/world/Player"
var camera = "/root/world/ShakyCamera"

func add_trauma(trauma):
	if (camera):
		camera.add_trauma(trauma)
		
onready var players = []
onready var enemies = []

onready var num_enemies : int = 0
onready var max_enemies : int = 30
onready var min_enemies : int = 15
onready var spawners_active : bool = false

func register_unit(unit : NodePath, friendly : bool = true) -> void:
	if (friendly):
		players.push_back(unit)
	else:
		enemies.push_back(unit)
		if (spawners_active):
			num_enemies += 1
			if (num_enemies >= max_enemies):
				toggle_spawners(friendly, false)
			
func unregister_unit(unit : NodePath, friendly : bool = true) -> void:
	if (friendly and players.find(unit) >= 0):
		players.remove(players.find(unit))
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
		targets = players
		
	var nearest = null
	if (len(targets) > 0):
		nearest = player
		var nearest_dist = -1
		for target in targets:
			if (get_node(target)):
				var curr = (get_node(target).global_position - pos).length_squared()
				if curr < nearest_dist or nearest_dist == -1:
					nearest = target
					nearest_dist = curr
			
	return nearest
	
	# Spawner Logic
	
onready var ally_spawners = []
onready var enemy_spawners = []	
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

func _unhandled_key_input(event):
	if (Input.is_action_just_pressed("debug_reset")):
		get_tree().change_scene("res://Scenes/Testing.tscn")
		get_tree().get_root().get_node(player).reset()
		spawners_active = false
	if (Input.is_action_just_pressed("debug_start")):
		print("started!")
		spawners_active = true
		toggle_spawners(false, spawners_active)
