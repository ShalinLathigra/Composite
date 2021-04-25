extends Resource
class_name Unit_Resource

export (int, 1, 100) var health
export (float, 0, 300) var speed
export (Vector2) var override_scale = Vector2(1,1)

export (float, 0, 1200) var chase_rad
export (float, 0.0, 10.0) var max_chase_timer
export (float, 0.0, 2.0) var attack_cooldown
export (int, 0, 100) var attack_damage
export (float, 0.0, 1.0) var hit_trauma
export (float, 0.0, 1.0) var death_shake


export (int, FLAGS, "is_melee", "is_ranged") var type

export (Array) var hurt_frames

export (Resource) var gun_prefab
export (Resource) var gun_override_resource
export (int, FLAGS, "BASE", "NONE") var bullet_type

export (float, -32, 600) var attack_start_range
export (float, 100, 1200) var attack_end_range


export (float, -50.0, 50.0) var volume
export (int) var clip
