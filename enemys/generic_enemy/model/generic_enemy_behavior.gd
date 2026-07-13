extends Node

static var rng : RandomNumberGenerator = RandomNumberGenerator.new()

@onready var body : GenericEnemyModel = $".."

@onready var navegator : Navegator = $"../Navegator"

@onready var animation_tree : AnimationTree = $"../AnimationTree"

@export var guns : Dictionary[GenericEnemyModel.GunType,GunInfo]

@export var Desired_distances : Dictionary[GenericEnemyModel.GunType,Vector2]

@onready var muzle : Node3D = $"../muzle"

var in_combat : bool = true

var cool_down : float = 2.0

var reload_time : float = 0.0

var ammon_on_mag : int = -1



func shot(info:GunInfo) -> void:
	
	if not info:
		return
	
	$"../ik_targets/AnimationPlayer".play("shot")
	
	cool_down = info.fire_rate
	
	$"../muzle".look_at(Player.player.global_position)
	$"../muzle".rotation.y = PI
	
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
			

var state : Callable = process_movement
@onready var visualizer : RayCast3D = $"../muzle/player_visualizer"
var is_player_visible : bool = false
func check_player_visibility() -> bool:
	is_player_visible = false
	
	if Player.player:
		visualizer.look_at(Player.player.global_position)
		visualizer.force_raycast_update()
		if visualizer.is_colliding() and visualizer.get_collider() == Player.player:
			is_player_visible = true
	
	return is_player_visible

var view_timer : Timer
func _ready() -> void:
	ammon_on_mag = guns[body.current_gun_type].ammon_capacity
	
	visualizer.add_exception(body)
	
	view_timer = Timer.new()
	add_child(view_timer)
	view_timer.autostart = true
	view_timer.one_shot = false
	view_timer.start()
	view_timer.wait_time = rng.randf_range(0.4,0.8)
	view_timer.timeout.connect(check_player_visibility)

func process_movement(delta:float) -> void:
	
	navegator.is_navegating = Player.player.global_position.distance_to(get_parent().global_position) > 5.0
	
	if navegator.is_navegating:
		navegator.look_target =  Navegator.LookTarget.DIRECTION
		animation_tree.set("parameters/Transition/transition_request","walk")
	else:
		navegator.look_target =  Navegator.LookTarget.TARGET
		animation_tree.set("parameters/Transition/transition_request","idle")
	
	if is_player_visible:
		state = process_shot

func process_shot(delta:float) -> void:
	
	navegator.is_navegating = false
	
	navegator.look_target =  Navegator.LookTarget.TARGET
	animation_tree.set("parameters/Transition/transition_request","idle")
	
	if cool_down <= 0 and reload_time <= 0:
		shot(guns[body.current_gun_type])
	
	if not is_player_visible:
		state = process_movement
	



func _physics_process(delta: float) -> void:
	if in_combat and Player.player:
		
		reload_time -= delta
		cool_down -= delta
		
		navegator.target_position = Player.player.global_position
		state.call(delta)
		
