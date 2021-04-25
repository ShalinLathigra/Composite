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

const planning_scene = preload("res://Scenes/Planning.tscn")
const level_scene = preload("res://Scenes/Level.tscn")

const pickups = {
	PICKUPS.AMMO : preload("res://Components/PickUps/Instanceable/AmmoPickUp.tscn"),
	PICKUPS.SHIELD : preload("res://Components/PickUps/Instanceable/ShieldPickUp.tscn"),
}

enum UNIT_TYPES {
	M_,
	M_FAST,
	M_SLOW,
	R_,
}
const unit_scenes = {
	UNIT_TYPES.M_ : preload("res://Components/Units/Instanceable/Typed/M_.tscn"),
	UNIT_TYPES.M_FAST : preload("res://Components/Units/Instanceable/Typed/M_Fast.tscn"),
	UNIT_TYPES.M_SLOW : preload("res://Components/Units/Instanceable/Typed/M_Slow.tscn"),
	UNIT_TYPES.R_ : preload("res://Components/Units/Instanceable/Typed/R_.tscn"),
}

var world = "/root/world"
var level = "/root/world/level"
var planner = "/root/world/group_planner"
var player = "/root/world/player"
var camera = "/root/world/ShakyCamera"
var enemyCollector = "/root/world/EnemyCollector"

var time_factor : float = 1.0
var level_active : bool = true

func add_trauma(trauma):
	if (camera):
		camera.add_trauma(trauma)
