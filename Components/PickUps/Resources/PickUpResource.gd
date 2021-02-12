extends Resource
class_name PickUp

export (int, FLAGS, "Ammo", "Shield") var type
export (float) var delta

signal picked_up (type, delta)

func pick_up(target):
	emit_signal("picked_up", self, type, delta)
