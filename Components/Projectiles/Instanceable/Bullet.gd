extends Area2D
class_name Bullet

export (Resource) var res

onready var anims = {
	GLOBAL.SHOOT : "moving",
	GLOBAL.HIT : "hit"
}

var dir = Vector2(0,0)

onready var state = GLOBAL.SHOOT

func _ready():
	$Sprite.frames = res.frames
	
	
func _process(delta):
	$Sprite.play(anims[state])
	$Sprite.flip_v = dir.x < 0
	
func _physics_process(delta):
	if (state == GLOBAL.SHOOT):
		position += dir * res.move_rate * delta

func _on_PlayerBullet_body_entered(body):
	state = GLOBAL.HIT
	if (body.is_in_group("Entity")):
		body.receive_hit(res.damage)


func _on_Sprite_animation_finished():
	if (state == GLOBAL.HIT):
		queue_free()
