extends Particles2D

export (Array) var enemy_types
export (int, 0, 3000) var min_spawn_time
export (int, 0, 6000) var max_spawn_time

export (bool) var friendly = false

onready var to_next_spawn = max_spawn_time
onready var last_spawn = OS.get_ticks_msec()

onready var active = false

func _ready():
	max_spawn_time = max(min_spawn_time, max_spawn_time)
	get_node(GLOBAL.level).register_spawner(get_path(), friendly)

func _process(_delta):
	if (OS.get_ticks_msec() > last_spawn + to_next_spawn and active):
		spawn_unit()
		
		last_spawn = OS.get_ticks_msec()
		to_next_spawn = rand_range(0.0, 1.0) * (max_spawn_time - min_spawn_time) + min_spawn_time

func spawn_unit():
	var new_enemy : Unit = enemy_types[randi() % enemy_types.size()].instance()
	new_enemy.global_position = global_position
	get_node(GLOBAL.level).add_unit(new_enemy, friendly, true)
	
func set_active(act : bool = false):
	active = act
