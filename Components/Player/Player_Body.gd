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
export (Color) var mod = Color.cyan

signal needs_update()
	
func _ready():
	$Gun.bullet_layer = 8
	$Gun.bullet_mask = 2
	$Gun.mod = mod
	
	$Gun.connect("needs_update", get_node(".."), "update_ui")
	connect("needs_update", get_node(".."), "update_ui")

func _process(_delta):
	if (self.body_state != GLOBAL.HURT and get_node(GLOBAL.player).active and GLOBAL.level_active):
		var to_mouse = (get_global_mouse_position() - global_position).normalized()
		
		# Handle Player Body Direction
		body_state = GLOBAL.IDLE
		flip_h = (to_mouse.x) < 0.0
		
		# Handle Rotation of Gun
		$Gun.rotation_degrees = rad2deg(to_mouse.angle())
		
		# Handle Shooting
		if (Input.is_action_pressed("player_shoot")):
			if $Gun.shoot(true):
				body_state = GLOBAL.SHOOT
				
			emit_signal("needs_update")
			
		if (Input.is_action_just_pressed("player_swap")):
			next_gun()
			$Gun.check_ammo()
			emit_signal("needs_update")

	# Play Current Body Animation
	play(anims[body_state])
	
func _on_Body_animation_finished():
	if (body_state == GLOBAL.HURT):
		body_state = GLOBAL.IDLE

func get_slow_amount():
	return 1.0 - $Gun.slow_amount
	
func receive_hit(damage : int, trauma : float):
	get_node("../Player").receive_hit(damage, trauma)
	AudioManager.play_sound(AudioManager.BONE_CRUNCH, .01)
	AudioManager.play_sound(AudioManager.PUNCH_IMPACT, .01)

func next_gun():
	$Gun.update_res_from_gun()
	current_res = (current_res + 1) % len(gun_modes)
	$Gun.res = gun_modes[current_res]
	$Gun.update_gun_from_res()
	
func reset():
	for _i in range(gun_modes.size()):
		$Gun.reset()
		next_gun()
		

func add_ammo(amm):
	$Gun.add_ammo(amm)
	for i in range(len(gun_modes) - 1):
		var res = (current_res + 1 + i) % len(gun_modes)
		gun_modes[res].ammo = min(gun_modes[res].ammo_cap, gun_modes[res].ammo + amm)
		gun_modes[res].mag = gun_modes[res].mag_cap
	emit_signal("needs_update")
