extends Resource
class_name ProjectileInfo

@export var faction : GlobalEnums.Faction

@export var damage : int = 1
@export var speed : float = -1
@export var distance : float = 10.0
@export var model : PackedScene
@export var radius : float = 0.1
@export var spaw_on_colision : PackedScene

@export var ricochet : int = 0
@export var penetrations : int = 0
@export var bullet_rise_and_drop : Vector2 = Vector2.ZERO # TODO
@export var explosion_info : ExplosionInfo # TODO
