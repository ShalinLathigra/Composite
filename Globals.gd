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
	BASE
}
const bullets = {
	BULLETS.BASE : preload("res://Components/Projectiles/Instanceable/Bullet.tscn")
	}

const ally_frames = preload("res://Components/Units/SpriteFrames/AllyFrames.tres")
const enemy_frames = preload("res://Components/Units/SpriteFrames/EnemyFrames.tres")

var player = "/root/world/Player"
var camera = "/root/world/ShakyCamera"

func add_trauma(trauma):
	if (camera):
		camera.add_trauma(trauma)
		
onready var players = []
onready var enemies = []

func register_unit(unit : NodePath, friendly : bool = true) -> void:
	if (friendly):
		players.push_back(unit)
	else:
		enemies.push_back(unit)
		
func unregister_unit(unit : NodePath, friendly : bool = true) -> void:
	if (friendly):
		players.remove(players.find(unit))
	else:
		enemies.remove(enemies.find(unit))
		
	get_node(unit).call_deferred("free")

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
