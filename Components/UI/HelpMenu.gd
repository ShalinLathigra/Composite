extends CanvasLayer

onready var help_active : bool = true

func set_active (a : bool):
	if (a):
		$Backdrop.visible = help_active
		$Backdrop/Text.visible = help_active
	else:
		$Backdrop.visible = false
		$Backdrop/Text.visible = false
	
func _input(event):
	if (Input.is_action_just_pressed("helpmenu_toggle")):
		help_active = !help_active
		$Backdrop.visible = help_active
		$Backdrop/Text.visible = help_active
