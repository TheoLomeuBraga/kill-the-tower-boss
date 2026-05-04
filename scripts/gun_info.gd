extends Resource
class_name GunInfo

@export var name : String
@export var special_type : String = ""

@export var ammon_consumption : int = 1
@export var ammon_capacity : int = 10
@export var reload_time : float = 1.0

@export var bullets_per_shot : int = 1
@export var fire_rate : float = 0.25
@export var spread : float = 0.2

@export var is_automatic :  bool = false

@export var projectile_info : ProjectileInfo = ProjectileInfo.new()
@export var shot_sound : AudioStream

@export var ammon_type : GlobalEnums.AmmonType = GlobalEnums.AmmonType.ANY
