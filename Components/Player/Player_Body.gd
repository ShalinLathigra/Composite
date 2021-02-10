extends AnimatedSprite

onready var body_state = GLOBAL.IDLE 

export (Array) var gun_modes
onready var current_res = 0

onready var anims = {
	GLOBAL.IDLE : "idle",
	GLOBAL.SHOOT : "shoot",
	GLOBAL.HURT : "hurt",
}

onready var gun_anchor = Vector2(0, -4.0)

func _ready():
	$Gun.bullet_layer = 8
	$Gun.bullet_mask = 2

func _process(_delta):
	
	if (self.body_state != GLOBAL.HURT):
		var to_mouse = (get_global_mouse_position() - global_position).normalized()
		
		# Handle Player Body Direction
		body_state = GLOBAL.IDLE
		flip_h = (to_mouse.x) < 0.0
		
		# Handle Rotation of Gun
		$Gun.rotation_degrees = rad2deg(to_mouse.angle())
		
		# Handle Shooting
		if (Input.is_action_pressed("player_shoot")):
			$Gun.shoot(true)
			body_state = GLOBAL.SHOOT
		if (Input.is_action_just_pressed("player_swap")):
			$Gun.update_res_from_gun()
			current_res = (current_res + 1) % len(gun_modes)
			$Gun.res = gun_modes[current_res]
			$Gun.update_gun_from_res()

	# Play Current Body Animation
	play(anims[body_state])
	
func _on_Body_animation_finished():
	if (body_state == GLOBAL.HURT):
		body_state = GLOBAL.IDLE


func receive_hit(damage : int, trauma : float):
	get_node("../Player").receive_hit(damage, trauma)
