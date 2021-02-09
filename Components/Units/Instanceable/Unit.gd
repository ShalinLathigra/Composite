extends KinematicBody2D

onready var anims = {
	GLOBAL.IDLE : "idle",
	GLOBAL.CHASE : "walk",
	GLOBAL.HURT : "oww",
	GLOBAL.DIE : "die",
	GLOBAL.HIT : "ponch",
	GLOBAL.SHOOT : "shoot"
	}

onready var state = GLOBAL.IDLE
onready var state_stack = [] 

export (Resource) var res
onready var health = res.health

export (bool) var friendly = true
onready var attack_cd = 0.0

var chase_timer = 0.0

var gun = null

var target = null
var path = []

func _ready():
	$CollisionShape2D.scale = res.override_scale
	$Sprite.scale = res.override_scale
	GLOBAL.register_unit(self.get_path(), friendly)
	
	if (friendly):
		collision_layer = 1
		collision_mask = 2
		$PunchHitBox.collision_layer = 16
		$PunchHitBox.collision_mask = 2
		$Sprite.frames = GLOBAL.ally_frames
	else:
		collision_layer = 2
		collision_mask = 17
		$PunchHitBox.collision_layer = 64
		$PunchHitBox.collision_mask = 17
		$Sprite.frames = GLOBAL.enemy_frames
		
	
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
			gun.bullet_mask = 6
		else:
			gun.bullet_layer = 4
			gun.bullet_mask = 1 + 8
			
		call_deferred("add_child", gun)
		
		

func push_state(st):
	self.state_stack.push_back(self.state)
	self.state = st

func pop_state():
	self.state = self.state_stack.pop_back()
	
func _physics_process(delta):
	match self.state:
		GLOBAL.IDLE:
			if (self.target):
				if (get_node(self.target)):
					chase_timer = res.max_chase_timer
					push_state(GLOBAL.CHASE)
				else:
					self.target = null
			else:
				self.target = GLOBAL.get_nearest(self.position, friendly)
		GLOBAL.CHASE:
			chase(delta)
		GLOBAL.SHOOT:
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
		move_and_slide(to_target.normalized() * res.speed, Vector2.UP)
		if res.type % 2 == 1:
			if target in near_entities:
				if self.attack_cd == 0.0:
					push_state(GLOBAL.HIT)
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
	get_node(GLOBAL.camera).add_trauma(res.death_shake)
	GLOBAL.unregister_unit(self.get_path())


func _process(_delta):
	$Sprite.play(self.anims[self.state])
	
func _on_Sprite_animation_finished():
	if (self.state == GLOBAL.HURT or self.state == GLOBAL.HIT):
		pop_state()
		
func _on_Sprite_frame_changed():
	if (self.state == GLOBAL.HIT):
		if ($Sprite.frame in res.hurt_frames):
			for entity in near_entities:
				get_node(entity).receive_hit(res.attack_damage, res.hit_trauma)
						
onready var near_entities = []

func _on_PunchHitBox_body_entered(body):
	if (body.is_in_group("Entity")):
		near_entities.push_back(body.get_path())

func _on_PunchHitBox_body_exited(body):
	if (body.is_in_group("Entity")):
		near_entities.remove(near_entities.find(body.get_path()))