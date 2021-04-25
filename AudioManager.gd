extends Node

enum {
	WHOOSH,
	SWORD_WHOOSH,
	BONE_CRUNCH,
	PUNCH_IMPACT,
	PISTOL,
	RAPID_GUN,
	ROCKET_LAUNCH,
	EXPLOSION,
	DIE,
}
onready var audio_samples = {
	WHOOSH : preload("res://Sounds/DIE.wav"),
	SWORD_WHOOSH : preload("res://Sounds/SWORD_WHOOSH.wav"),
	BONE_CRUNCH : preload("res://Sounds/BONE_CRUNCH.wav"),
	PUNCH_IMPACT : preload("res://Sounds/PUNCH_IMPACT.wav"),
	PISTOL : preload("res://Sounds/PISTOL.wav"),
	RAPID_GUN : preload("res://Sounds/RAPID_GUN.wav"),
	ROCKET_LAUNCH : preload("res://Sounds/ROCKET_LAUNCH.wav"),
	EXPLOSION : preload("res://Sounds/EXPLOSION.wav"),
	DIE : preload("res://Sounds/DIE.wav"),
}

func play_sound(i : int, v : float) -> void:
	var a = AudioStreamPlayer.new()
	a.stream = audio_samples[i]
	a.volume_db = v
	get_tree().get_root().add_child(a)
	a.play()
	yield(a, "finished")
	a.queue_free()
