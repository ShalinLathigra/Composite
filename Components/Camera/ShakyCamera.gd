extends Camera2D

export var ro_decay = 0.8
export var max_delta = Vector2(30, 15)
export var max_roll = 0.05
export (NodePath) var target
export (float, 0.05, 0.9) var follow_rate = 0.1

export var trauma_pow = 2.0
onready var trauma = 0.0
onready var max_gun_trauma = 0.2

onready var noise = OpenSimplexNoise.new()
var noise_y = 0
export var noise_period = 4.0
export var noise_octaves = 2.0

func _ready():
	randomize()
	noise.seed = randi()
	noise.period = noise_period
	noise.octaves = noise_octaves
	
func is_gun_trauma_maxed():
	return trauma > max_gun_trauma
	
func add_trauma(t):
	self.trauma = min(self.trauma + t, 1.0)
	
func _process(delta):
	if (target):
		global_position = lerp(global_position, get_node(target).position, follow_rate * zoom.x)
		
	if (self.trauma):
		self.trauma = max(self.trauma-ro_decay*delta, 0.0)
		shake()
		
	# If player is left clicking, increase screen view
	# Otherwise, zoom should be proportional to vel.

func update_zoom(val):
	zoom = Vector2(0.5 + val,0.5 + val)
	
func shake():
	var amount = pow(self.trauma, trauma_pow)
	noise_y += 1
	rotation = max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
	offset.x = max_delta.x * amount * noise.get_noise_2d(noise.seed*2, noise_y)
	offset.y = max_delta.y * amount * noise.get_noise_2d(noise.seed*3, noise_y)
