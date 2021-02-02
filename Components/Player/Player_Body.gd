extends AnimatedSprite

onready var body_state = GLOBAL.IDLE 

onready var anims = {
	GLOBAL.IDLE : "idle",
	GLOBAL.SHOOT : "shoot",
	GLOBAL.HURT : "hurt",
}

onready var gun_anchor = Vector2(0, -4.0)

func _process(_delta):
	var to_mouse = (get_global_mouse_position() - global_position).normalized()
	
	# Handle Player Body Direction
	body_state = GLOBAL.IDLE
	flip_h = (to_mouse.x) < 0.0
	
	# Handle Rotation of Gun
	$Gun.rotation_degrees = rad2deg(to_mouse.angle())
	
	
	# Handle Shooting
	if (Input.is_action_pressed("player_shoot")):
		$Gun.shoot()
		body_state = GLOBAL.SHOOT

	# Play Current Body Animation
	play(anims[body_state])
