extends Area2D
class_name Bullet

export (Resource) var res

onready var anims = {
	GLOBAL.SHOOT : "moving",
	GLOBAL.HIT : "hit"
}

var dir = Vector2(0,0)

onready var state = GLOBAL.SHOOT
var mod = Color.white

func _ready():
	$Sprite.frames = res.frames
	$Sprite.self_modulate = mod
	$Sprite.self_modulate.r *= 1.2
	$Sprite.self_modulate.g *= 1.2
	$Sprite.self_modulate.b *= 1.2
	
	$CPUParticles2D.self_modulate = $Sprite.self_modulate
	
func _process(_delta):
	$Sprite.play(anims[state])
	$Sprite.flip_v = dir.x < 0
	
func _physics_process(delta):
	if (state == GLOBAL.SHOOT):
		position += dir * res.move_rate * delta * GLOBAL.time_factor

func _on_Sprite_animation_finished():
	if (state == GLOBAL.HIT):
		queue_free()


func _on_Bullet_body_entered(body):
	state = GLOBAL.HIT
	if (body.is_in_group("Entity")):

		collision_mask = 0
		collision_layer = 0
		body.receive_hit(res.damage, res.trauma)
		AudioManager.play_sound(res.clip, res.volume)
	


func _on_Bullet_area_entered(area):
	state = GLOBAL.HIT
	if (area.is_in_group("Entity")):
		collision_mask = 0
		collision_layer = 0
		area.receive_hit(res.damage, res.trauma)
