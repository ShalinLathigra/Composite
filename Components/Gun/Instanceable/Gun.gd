extends Node2D
class_name Gun_Base

export (Resource) var res

onready var anims = {
	GLOBAL.IDLE : "Idle",
	GLOBAL.SHOOT : "Shoot"
}

onready var state = GLOBAL.IDLE
onready var cd = 0.0

onready var ammo_cap = res.ammo_cap
onready var mag_cap = res.mag_cap

onready var ammo = res.ammo_cap
onready var mag = res.mag_cap

onready var shots_per_second = res.shots_per_second
onready var slow_amount = res.slow_amount
onready var bullets_per_shot = res.bullets_per_shot
onready var max_reload_time = res.max_reload_time
onready var reload_time = 0.0

onready var bullet_type = res.bullet_type - 1
onready var shake = res.shake
onready var trauma = res.trauma

onready var bullet_override_resource = res.bullet_override_resource

var mod = Color.white

var bullet_layer = 0
var bullet_mask = 0

var friendly = false

signal needs_update()

func _ready():
	$Gun.frames = res.frames
	$Gun.position.x = res.hold_distance
	$Gun/Muzzle.position.x = res.muzzle_dist
	
func shoot(add_trauma):
	if (cd == 0.0 and mag > 0):
		
		# Gun Housekeeping
		state = GLOBAL.SHOOT
		cd = 1.0 / shots_per_second
		for i in range(bullets_per_shot):
			mag -= 1
			if (mag == 0):
				$ReloadTimer.start(max_reload_time)
			# Bullet Instancing
			var bullet_instance = GLOBAL.bullets[bullet_type].instance()
			
			#bullet_instance.res = res.bullet_res
			bullet_instance.global_position = $Gun/Muzzle.global_position
			var angle = rotation_degrees + rand_range(-1.0,1.0) * shake
			bullet_instance.rotation_degrees = angle
			
			bullet_instance.dir = Vector2(cos(deg2rad(angle)), sin(deg2rad(angle)))
			bullet_instance.collision_mask = bullet_mask
			bullet_instance.collision_layer = bullet_layer
			bullet_instance.mod = mod
			
			if (bullet_override_resource):
				bullet_instance.res = bullet_override_resource
			get_node("/root/world").add_child(bullet_instance)
		
		if (add_trauma): 
			add_trauma()
		
		emit_signal("needs_update")
		
	return mag > 0
		
func add_trauma():
	# Camera Shake handled seperately. Called by owner.
	if (!get_node(GLOBAL.camera).is_gun_trauma_maxed()):
		get_node(GLOBAL.camera).add_trauma(trauma)
		
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
		emit_signal("needs_update")
		


# Update and Load Gun from/to resource

func update_gun_from_res():
	ammo_cap = res.ammo_cap
	mag_cap = res.mag_cap

	ammo = res.ammo
	mag = res.mag
	
	shots_per_second = res.shots_per_second
	slow_amount = res.slow_amount
	bullets_per_shot = res.bullets_per_shot
	max_reload_time = res.max_reload_time

	bullet_type = res.bullet_type - 1
	shake = res.shake
	trauma = res.trauma

	bullet_override_resource = res.bullet_override_resource
	$Gun.frames = res.frames
	$Gun.position.x = res.hold_distance
	$Gun/Muzzle.position.x = res.muzzle_dist
	
func update_res_from_gun():
	res.ammo_cap = ammo_cap
	res.mag_cap = mag_cap
	
	res.ammo = ammo
	res.mag = mag

	res.shots_per_second = shots_per_second
	res.slow_amount = slow_amount
	res.bullets_per_shot = bullets_per_shot
	res.max_reload_time = max_reload_time

	res.bullet_type = bullet_type + 1
	res.shake = shake
	res.trauma = trauma

	res.bullet_override_resource = bullet_override_resource
	res.frames = $Gun.frames
	res.hold_distance = $Gun.position.length()
	res.muzzle_dist = $Gun/Muzzle.position.length()

func reset():
	ammo = ammo_cap
	mag = mag_cap
	
	update_res_from_gun()

func add_ammo(add):
	ammo = min(ammo_cap, ammo + add + mag)
	mag = mag_cap
	cd = 0.0
	$ReloadTimer.stop()
	emit_signal("needs_update")
		
	
func check_ammo():
	if (mag == 0 and ammo > 0):
		$ReloadTimer.start(max_reload_time)
