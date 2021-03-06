extends Resource
class_name Gun_Resource

export (SpriteFrames) var frames
export (float, 0.5, 50) var shots_per_second
export (float, 0.0, 1.0) var slow_amount
export (int, 0, 50) var bullets_per_shot
export (int, 1, 100) var mag_cap
export (int, 1, 300) var ammo_cap
export (int) var mag = mag_cap
export (int) var ammo = ammo_cap
export (float, 0.1, 10) var max_reload_time
export (float) var reload_time
#export (int, 1, 10) var bullets_per_shot

export (float, 0.5, 32.0) var shake
export (float, 0.5, 32.0) var muzzle_dist
export (float, 0.05, 0.5) var trauma
export (float, 8.0, 128.0) var hold_distance
export (float, -50.0, 50.0) var volume
export (int) var clip

export (int, FLAGS, "BASE", "ROCKET") var bullet_type
export (Resource) var bullet_override_resource
