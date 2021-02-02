extends Node2D
class_name Gun_Base

export (Resource) var res

onready var anims = {
	GLOBAL.IDLE : "Idle",
	GLOBAL.SHOOT : "Shoot"
}

export (NodePath) var cam

onready var state = GLOBAL.IDLE
onready var cd = 0.0

onready var ammo_cap = res.ammo_cap
onready var mag_cap = res.mag_cap

onready var ammo = ammo_cap
onready var mag = mag_cap

var friendly = false

func _ready():
	$Gun.frames = res.frames
	$Gun.position.x = res.hold_distance
	
func shoot():
	if (cd == 0.0 and mag > 0):
		
		# Gun Housekeeping
		state = GLOBAL.SHOOT
		cd = 1.0 / res.shots_per_second
		mag -= 1
		if (mag == 0):
			$ReloadTimer.start(res.reload_time)
		
		# Bullet Instancing
		var bullet_instance = GLOBAL.bullet.instance()
		get_node("/root/world").add_child(bullet_instance)
		
		bullet_instance.res = res.bullet_res
		bullet_instance.global_position = $Muzzle.global_position
		var angle = rotation_degrees + rand_range(-1.0,1.0) * res.shake
		bullet_instance.rotation_degrees = angle
		
		bullet_instance.dir = Vector2(cos(deg2rad(angle)), sin(deg2rad(angle)))
		bullet_instance.collision_mask = 6
		
		# Camera Shake
		if (!get_node(cam).is_gun_trauma_maxed()):
			get_node(cam).add_trauma(res.trauma)
		
		
func _process(delta):
	# Handle Gun Cooldowns
	if (cd > 0): 
		cd = max(cd - delta, 0.0)
		if (cd <= 0.0):
			state = GLOBAL.IDLE
			
	$Gun.flip_v = rotation_degrees > 90 or rotation_degrees < -90
	$Gun.play(anims[state])


func _on_ReloadTimer_timeout():
	if (ammo > 0):
		mag = min(mag_cap, ammo)
		ammo -= mag
