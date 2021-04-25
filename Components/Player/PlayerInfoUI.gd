extends CanvasLayer

onready var health_string = "Health: %s / %s"
onready var ammo_string = "Ammo: %s / %s"
onready var mag_string = "Magazine: %s / %s"

onready var legs = "../../player"
onready var gun = "../../player/Body/Gun"

func update_ui():
	$Backdrop/HealthLabel.text = health_string % [get_node(legs).health, get_node(legs).max_health]
	$Backdrop/AmmoLabel.text = ammo_string % [get_node(gun).ammo, get_node(gun).ammo_cap]
	$Backdrop/MagLabel.text = mag_string % [get_node(gun).mag, get_node(gun).mag_cap]
