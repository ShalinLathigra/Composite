extends KinematicBody2D

export (float, 0, 600) var walk_speed = 100
export (float, 0, 600) var run_speed = 300
export (float, 0, 1) var friction = 0.05

onready var vel = Vector2()

onready var anims = {
	GLOBAL.IDLE : "idle",
	GLOBAL.WALK : "walk",
	GLOBAL.RUN : "run",
	GLOBAL.HURT : "hurt",
}

var leg_state = GLOBAL.IDLE

func process_input():
	var direction = Vector2(0,0)
	if (Input.is_action_pressed("player_left")):
		direction.x -= 1.0
		$Legs.flip_h = true
	if (Input.is_action_pressed("player_right")):
		direction.x += 1.0
		$Legs.flip_h = false
	if (Input.is_action_pressed("player_up")):
		direction.y -= 1.0
	if (Input.is_action_pressed("player_down")):
		direction.y += 1.0
	if (direction != Vector2(0,0)):
		var speed = run_speed
		leg_state = GLOBAL.RUN
		if (Input.is_action_pressed("player_walk")):
			speed = walk_speed
			leg_state = GLOBAL.WALK
		vel = direction.normalized() * speed
	else:
		leg_state = GLOBAL.IDLE
		
	#This would override the current state

func _physics_process(delta):
	process_input()
	move_and_slide(vel, Vector2.UP)
	vel = lerp(vel, Vector2(0,0), friction)
	
	$Legs.play(anims[leg_state])
