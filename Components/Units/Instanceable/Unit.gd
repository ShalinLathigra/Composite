extends KinematicBody2D
class_name Unit

onready var anims = {
	GLOBAL.DIE : "die",
	GLOBAL.IDLE : "idle",
	GLOBAL.HURT : "oww",
	GLOBAL.HIT : "ponch",
	GLOBAL.CHASE : "run",
	GLOBAL.SHOOT : "shoot",
	}

onready var state = GLOBAL.IDLE
onready var state_stack = [] 

export (Resource) var res
onready var health = res.health

export (bool) var friendly = true
onready var attack_cd = 0.0

export (float) var drop_ammo = .025
export (float) var drop_shield = .0125

onready var mod = Color.white

onready var priority = 0

onready var active : bool = true

var chase_timer = 0.0

var gun = null

var target = null
var path = []

var followers = []

func get_followers() -> Array:
	return followers
	
func set_followers(a : Array) -> void:
	followers = a
	
func clear_followers() -> Array:
	var a : Array = followers
	followers = []
	return a
	
func set_active(a : bool):
	active = a

func _ready():
	$CollisionShape2D.scale = res.override_scale
	$Sprite.scale = res.override_scale
	get_node(GLOBAL.level).register_unit(self.get_path(), friendly)
			
	if res.type - 2 >= 0:
		# If ranged, instantiate res.gun_prefab
		# Apply res.gun_override_resource
		# Set gun.bullet_type to res.bullet_type
		gun = res.gun_prefab.instance()
		if (res.gun_override_resource):
			gun.res = res.gun_override_resource
		if (res.bullet_type != 2):
			gun.res.bullet_type = res.bullet_type
		if (friendly):
			gun.bullet_layer = 8
			gun.bullet_mask = 2
		else:
			gun.bullet_layer = 4
			gun.bullet_mask = 128
		gun.mod = mod
		call_deferred("add_child", gun)
		gun.self_modulate = Color("00ffffff")
		
	set_collision_masks()
		
		
func set_collision_masks():
	if (friendly):
		collision_layer = 16
		collision_mask = 2
		$PunchHitBox.collision_layer = 16
		$PunchHitBox.collision_mask = 2
		#$Sprite.frames = GLOBAL.ally_frames
		mod = Color.cadetblue
	else:
		collision_layer = 2
		collision_mask = 16
		$PunchHitBox.collision_layer = 64
		$PunchHitBox.collision_mask = 1 + 16
		#$Sprite.frames = GLOBAL.enemy_frames
		mod = Color.tomato
	if res.type - 2 >= 0:
		if (friendly):
			gun.bullet_layer = 8
			gun.bullet_mask = 2
		else:
			gun.bullet_layer = 4
			gun.bullet_mask = 128
			
func push_state(st):
	self.state_stack.push_back(self.state)
	self.state = st

func pop_state():
	self.state = self.state_stack.pop_back()
	

	
func _physics_process(delta):
	if (active):
		match self.state:
			GLOBAL.IDLE:
				if (self.target):
					if (get_node(self.target)):
						chase_timer = res.max_chase_timer
						push_state(GLOBAL.CHASE)
					else:
						self.target = null
				else:
					self.target = get_node(GLOBAL.level).get_nearest(self.position, friendly)
					
			GLOBAL.CHASE:
				chase(delta)
				
			GLOBAL.SHOOT:
				if (GLOBAL.level_active):
					shoot()
				
			GLOBAL.DIE:
				die()
				
		self.attack_cd = max(self.attack_cd - delta, 0.0)

func chase(delta):
	if get_node(self.target):
		var to_target = Vector2((get_node(self.target).global_position - global_position))
		if to_target.length_squared() > pow(res.chase_rad, 2.0):
			chase_timer = max(chase_timer - delta, 0.0)
			if chase_timer == 0.0:
				pop_state()
		if to_target.length_squared() > pow(res.attack_start_range * 2.0 * res.override_scale.x, 2.0):
			move_and_slide(to_target.normalized() * res.speed * GLOBAL.time_factor, Vector2.UP)
			if res.type % 2 == 1:
				if $Sprite.flip_h != (to_target.x < 0):
					$Sprite.flip_h = (to_target.x) < 0.0
					if ($Sprite.flip_h): 
						$PunchHitBox.position.x = -res.attack_start_range
					else:
						$PunchHitBox.position.x = res.attack_start_range
		if res.type % 2 == 1:
			if target in near_entities:
				if self.attack_cd == 0.0 and GLOBAL.level_active:
					push_state(GLOBAL.HIT)
					AudioManager.play_sound(res.clip, res.volume)
					self.attack_cd = res.attack_cooldown
		elif res.type - 2 >= 0:
			if to_target.length_squared() <= pow(res.attack_start_range, 2.0):
				push_state(GLOBAL.SHOOT)
				
	else:
		pop_state()

func shoot():
	if get_node(self.target):
		var to_target = Vector2((get_node(self.target).global_position - global_position))
		$Sprite.flip_h = (to_target.x) < 0.0
		$Gun.rotation_degrees = rad2deg(to_target.angle())
		if to_target.length_squared() >= pow(res.attack_end_range, 2.0):
			pop_state()
		else:
			$Gun.shoot(false)
	else:
		pop_state()
	
# Damage/Death/Loot ########################################################################
func receive_hit(damage, _trauma):
	self.health -= damage
	if (self.health > 0):
		push_state(GLOBAL.HURT)
	else:
		push_state(GLOBAL.DIE)
	
func die():
	self.state_stack.clear()
	self.state = GLOBAL.DIE
	collision_mask = 0
	collision_layer = 0
	z_index -= 2
	
	get_node(GLOBAL.camera).add_trauma(res.death_shake)
	
	if (rand_range(0.0, 1.0) < drop_ammo):
		drop_pickup(GLOBAL.PICKUPS.AMMO)
	if (rand_range(0.0, 1.0) < drop_shield):
		drop_pickup(GLOBAL.PICKUPS.SHIELD)
		
	get_node(GLOBAL.level).unregister_unit(self.get_path(), friendly)
	set_physics_process(false)

func drop_pickup(type):
	var ang = rand_range(0.0, 360.0)
	var dir = Vector2(sin(deg2rad(ang)), cos(deg2rad(ang)))
	
	var p_up = GLOBAL.pickups[type].instance()
	p_up.global_position = global_position + dir * rand_range(1.0, 100.0)
	get_tree().get_root().add_child(p_up)

# Play Animations ########################################################################
func _process(_delta):
	$Sprite.play(self.anims[self.state])
	if (self.state == GLOBAL.DIE):
		set_process(false)
		yield(get_tree().create_timer(2.5), "timeout")
		despawn()
		
func despawn():
	call_deferred("queue_free")
	
func set_selected(s):
	$Sprite.material.set_shader_param("selected", s)
	if (followers.size() > 0):
		for f in followers:
			f.set_selected(s * 0.25)
	pass

# Signal Handlers ########################################################################
func _on_Sprite_animation_finished():
	if (self.state == GLOBAL.HURT or self.state == GLOBAL.HIT):
		pop_state()

func _on_Sprite_frame_changed():
	if (self.state == GLOBAL.HIT):
		if ($Sprite.frame in res.hurt_frames):
			AudioManager.play_sound(AudioManager.PUNCH_IMPACT, -20)
			for entity in near_entities:
				get_node(entity).receive_hit(res.attack_damage, res.hit_trauma)

onready var near_entities = []

func _on_PunchHitBox_body_entered(body):
	if (body.is_in_group("Entity")):
		near_entities.push_back(body.get_path())

func _on_PunchHitBox_body_exited(body):
	if (body.is_in_group("Entity")):
		near_entities.remove(near_entities.find(body.get_path()))
