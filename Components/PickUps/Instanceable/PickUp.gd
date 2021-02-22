extends Area2D

export (Resource) var res
onready var type = res.type
onready var delta = res.delta

func _on_PickUp_body_entered(body):
	body.apply_pick_up(self)
	$PassiveParticles.emitting = false
	$PassiveParticles2.emitting = false
	$BurstParticles.one_shot = true
	$BurstParticles.emitting = true
	
	collision_layer = 0
	collision_mask = 0
	$Sprite.visible = false
	
	yield(get_tree().create_timer($BurstParticles.lifetime), "timeout")
	call_deferred("queue_free")
