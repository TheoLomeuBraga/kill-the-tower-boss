extends Resource
class_name ChargeShotInfo

@export var ammon_type : GlobalEnums.AmmonType = GlobalEnums.AmmonType.NONE
@export var ammon_consumption : int = 10
@export var bullets_per_shot : int = 1
@export var spread : float = 0.2
@export var charge_time : float = 1.0
@export var spawn_effect : PackedScene
@export var projectile_info : ProjectileInfo = ProjectileInfo.new()
@export var charge_sound : AudioStream
