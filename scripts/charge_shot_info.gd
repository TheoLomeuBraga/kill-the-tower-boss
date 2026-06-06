extends Resource
class_name ChargeShotInfo

@export var ammon_type : GlobalEnums.AmmonType = GlobalEnums.AmmonType.NONE
@export var ammon_consumption : int = 10
@export var bullets_per_shot : int = 1
@export var spread : float = 0.1
@export var charge_time : float = 1.0
@export var projectile_info : ProjectileInfo = ProjectileInfo.new()
@export var knock_back : float = 1.0
@export var fire_rate : float = 1.0

@export var charge_sound : AudioStream
@export var charged_sound : AudioStream
