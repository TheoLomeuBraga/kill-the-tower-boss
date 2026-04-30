extends Resource
class_name GunInfo

@export var name : String
@export var special_type : String = ""

@export var bullets_per_shot : int = 1
@export var bullet_capacity : int = 10
@export var fire_rate : float = 0.25
@export var reload_time : float = 2.0
@export var spread : float = 0.2

@export var projectile_info : ProjectileInfo = ProjectileInfo.new()
