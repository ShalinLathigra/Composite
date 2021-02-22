extends "res://Components/Projectiles/Instanceable/Bullet.gd"

class_name Rocket

onready var near_objects = []

func _ready():
	$RocketArea.collision_mask = collision_mask
	$RocketArea.collision_layer = collision_layer
	get_node(GLOBAL.camera).add_trauma(res.trauma)
	._ready()
	
func _on_RocketArea_body_exited(body):
	near_objects.remove(near_objects.find(body))
func _on_RocketArea_body_entered(body):
	near_objects.push_back(body)

func hit():
	$Sprite.scale = Vector2(2.0, 2.0)
	state = GLOBAL.HIT
	for target in near_objects:
		if (target.is_in_group("Entity")):
			collision_mask = 0
			collision_layer = 0
			target.receive_hit(res.damage, res.trauma)
	get_node(GLOBAL.camera).add_trauma(res.trauma)

func _on_Bullet_body_entered(_body):
	hit()

func _on_Bullet_area_entered(_area):
	hit()
