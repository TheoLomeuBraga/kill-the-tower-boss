extends Resource
class_name GunInfo

@export var model : PackedScene
@export var special_type : GlobalEnums.WeponTime = GlobalEnums.WeponTime.NORMAL

@export var ammon_consumption : int = 1
@export var ammon_capacity : int = 10
@export var reload_time : float = 1.0
@export var inventory_reload_time : float = 2.0
@export var reload_audio : AudioStream

@export var bullets_per_shot : int = 1
@export var fire_rate : float = 0.25
@export var spread : float = 0.2

@export var is_automatic :  bool = false

@export var projectile_info : ProjectileInfo = ProjectileInfo.new()
@export var spawn_effect : PackedScene

@export var ammon_type : GlobalEnums.AmmonType = GlobalEnums.AmmonType.NONE

@export var knock_back : float = 0.0
