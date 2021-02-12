extends CanvasLayer

func _input(event):
	if (Input.is_action_just_pressed("helpmenu_toggle")):
		$Backdrop.visible = !$Backdrop.visible
		$Text.visible = !$Text.visible
