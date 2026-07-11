extends Node

static var rng : RandomNumberGenerator = RandomNumberGenerator.new()

@onready var model : GenericEnemyModel = $".."

@onready var navegator : Navegator = $"../Navegator"

@onready var animation_tree : AnimationTree = $"../AnimationTree"

@export var guns : Dictionary[GenericEnemyModel.GunType,GunInfo]

@onready var muzle : Node3D = $"../muzle"

var in_combat : bool = true

var cool_down : float = 2.0

var reload_time : float = 0.0

var ammon_on_mag : int = -1

func _ready() -> void:
	ammon_on_mag = guns[model.current_gun_type].ammon_capacity

func shot(info:GunInfo) -> void:
	
	if not info:
		return
	
	cool_down = info.fire_rate
	
	for i : int in info.bullets_per_shot:
		
		var projectile : ProjectBehavior = ProjectBehavior.new()
		add_child(projectile)
		projectile.global_position = muzle.global_position
		projectile.muzle_position = muzle.global_position
		
		projectile.target_position = muzle.global_basis.z * -100.0
		
		projectile.global_rotation = muzle.global_rotation
		
		var spread : float = info.spread
		var vec_spread : Vector3 = Vector3(rng.randf_range(-1.0,1.0),rng.randf_range(-1.0,1.0),rng.randf_range(-1.0,1.0))
		if vec_spread.length() > 1.0:
			vec_spread = vec_spread.normalized()
		vec_spread /= 1.0
		var aditional_rot : Vector3 = vec_spread * spread
		projectile.rotate_x(aditional_rot.x)
		projectile.rotate_y(aditional_rot.y)
		projectile.rotate_z(aditional_rot.z)
		
		projectile.data = info.projectile_info
		projectile.start()
	
	if info.ammon_consumption > 0:
		ammon_on_mag -= info.ammon_consumption
		if ammon_on_mag <= 0:
			ammon_on_mag = info.ammon_capacity
			reload_time = info.reload_time
			

func process_shot(delta: float) -> void:
	
	reload_time -= delta
	cool_down -= delta
	if cool_down <= 0 and reload_time <= 0:
		shot(guns[model.current_gun_type])
	
	

func process_movement(delta: float) -> void:
	if Player.player:
		navegator.target_position = Player.player.global_position
		navegator.is_navegating = Player.player.global_position.distance_to(get_parent().global_position) > 5.0
		
		if navegator.is_navegating:
			navegator.look_target =  Navegator.LookTarget.DIRECTION
			animation_tree.set("parameters/Transition/transition_request","walk")
		else:
			navegator.look_target =  Navegator.LookTarget.TARGET
			animation_tree.set("parameters/Transition/transition_request","idle")

func _physics_process(delta: float) -> void:
	if in_combat:
		
		process_movement(delta)
		process_shot(delta)
