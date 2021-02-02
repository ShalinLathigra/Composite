extends KinematicBody2D

onready var anims = {
	GLOBAL.IDLE : "idle",
	GLOBAL.WALK : "walk",
	GLOBAL.RUN : "run",
	GLOBAL.HURT : "oww"
	}

onready var state = GLOBAL.IDLE

export (int, 1, 100) var health

func _process(delta):
	if (state != GLOBAL.HURT):
		$Sprite.play(anims[state])
	
func receive_hit(damage):
	health -= damage
	state = GLOBAL.HURT
	$Sprite.play(anims[state])
	



func _on_Sprite_animation_finished():
	if (state == GLOBAL.HURT):
		state = GLOBAL.IDLE
