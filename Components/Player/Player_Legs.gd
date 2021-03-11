extends KinematicBody2D
class_name Player

export (float, 0, 600) var walk_speed = 100
export (float, 0, 600) var run_speed = 300
export (float, 0, 1) var friction = 0.05
export (int) var max_health = 100
onready var health = max_health

export (float) var dodge_cooldown;
onready var time_of_last_dodge = OS.get_ticks_msec();
export (int, 0, 5000) var i_time
onready var time_of_last_hit = 0
onready var shield_time = 0

onready var vel = Vector2()

var leader_paths : Array = []

var active : bool

onready var anims = {
	GLOBAL.IDLE : "idle",
	GLOBAL.WALK : "walk",
	GLOBAL.RUN : "run",
	GLOBAL.HURT : "hurt",
	GLOBAL.DODGE : "dodge",
}

onready var actions = {
	GLOBAL.IDLE : funcref( self, "idle"),
	GLOBAL.WALK : funcref( self, "move"),
	GLOBAL.RUN : funcref( self, "move"),
	GLOBAL.HURT : funcref( self, "idle"),
	GLOBAL.DODGE : funcref( self, "dodge"),
}

onready var lock_anims = [GLOBAL.HURT, GLOBAL.DIE, GLOBAL.DODGE]

var leg_state = GLOBAL.IDLE

signal update_ui ()

func update_ui():
	emit_signal("update_ui")
	

func _ready():
	if (!GLOBAL.player):
		GLOBAL.player = self
	get_node(GLOBAL.level).register_unit(self.get_path())
	
	connect("update_ui", $PlayerInfoUI, "update_ui")
	update_ui()
	
	PlayerData.set_leads_spawn_positions()
	
func set_active(a):
	active = a
	$PlayerInfoUI/Backdrop.visible = a

func process_input():
	if not (leg_state in lock_anims):
		var direction = Vector2(0,0)
		if (Input.is_action_pressed("player_left")):
			direction.x -= 1.0
			$Legs.flip_h = true
		if (Input.is_action_pressed("player_right")):
			direction.x += 1.0
			$Legs.flip_h = false
		if (Input.is_action_pressed("player_up")):
			direction.y -= 1.0
		if (Input.is_action_pressed("player_down")):
			direction.y += 1.0
		if (direction != Vector2(0,0)):
			var speed = run_speed
			leg_state = GLOBAL.RUN
			if (Input.is_action_pressed("player_dodge")):
				if (OS.get_ticks_msec() > time_of_last_dodge + dodge_cooldown):
					leg_state = GLOBAL.DODGE
					vel = direction.normalized()
					time_of_last_dodge = OS.get_ticks_msec()
			if ($Body.body_state == GLOBAL.SHOOT):
				speed *= $Body.get_slow_amount()
			vel = direction.normalized() * speed
		else:
			leg_state = GLOBAL.IDLE

func receive_hit(damage : int, trauma : float):
	if (leg_state == GLOBAL.DODGE or OS.get_ticks_msec() < time_of_last_hit + i_time or OS.get_ticks_msec() < shield_time):
		return
	
	self.health -= damage
	time_of_last_hit = OS.get_ticks_msec()
	$HurtPlayer.play("Hurt")
	
	update_ui()
	
	get_node(GLOBAL.camera).add_trauma(trauma)
	if (leg_state != GLOBAL.HURT):
		leg_state = GLOBAL.HURT
	if ($Body.body_state != GLOBAL.HURT):
		$Body.body_state = GLOBAL.HURT


func _process(_delta):
	# Deal with lasting pickup effects here
	if OS.get_ticks_msec() > shield_time:
		$Shield.visible = false
		set_process(false)
	
	
func _physics_process(_delta):
	if (active):
		process_input()	
		actions[leg_state].call_func(_delta)
		$Legs.play(anims[leg_state])
	

func _on_Legs_animation_finished():
	if (leg_state == GLOBAL.HURT):
		leg_state = GLOBAL.IDLE

# Actions =======================================================
# 				Dodge =======================================================
export (float) var dodge_dist;
export (float) var dodge_time;
func dodge(_delta):
	if (OS.get_ticks_msec() > time_of_last_dodge + dodge_time):
		time_of_last_dodge = OS.get_ticks_msec()
		leg_state = GLOBAL.IDLE
	else:
		move_and_slide(vel * (dodge_dist / dodge_time) * GLOBAL.time_factor, Vector2.UP)

# 				Idle =======================================================
func idle(_delta):
	pass
# 				Move =======================================================
func move(_delta):
	move_and_slide(vel * GLOBAL.time_factor, Vector2.UP)
	vel = lerp(vel, Vector2(0,0), friction)

func reset():
	health = max_health
	$Body.reset()
		
func apply_pick_up(pickup):
	match pickup.type:
		1: 
			$Body.add_ammo(pickup.delta)
		2: 
			shield_time = OS.get_ticks_msec() + pickup.delta
			$Shield.visible = true
			set_process(true)
