extends Navigation2D

func _ready():
	if (!GLOBAL.nav):
		GLOBAL.nav = self
