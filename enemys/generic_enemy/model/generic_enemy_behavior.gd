extends Node

static var rng : RandomNumberGenerator = RandomNumberGenerator.new()

@onready var body : GenericEnemyModel = $".."
@onready var navegator : Navegator = $"../Navegator"
@onready var animation_tree : AnimationTree = $"../AnimationTree"
@export var guns : Dictionary[GenericEnemyModel.GunType,GunInfo]
@export var desired_distances : Dictionary[GenericEnemyModel.GunType,Vector3]
@onready var muzle : Node3D = $"../muzle"

var in_combat : bool = true
var cool_down : float = 2.0
var reload_time : float = 0.0
var ammon_on_mag : int = -1

func calculate_target_future_point(target_pos:Vector3,target_vel:Vector3,target_dist:float,projectile_speed:float) -> Vector3:
	return target_pos + target_vel * (target_dist/projectile_speed)

func shot() -> void:
	
	var info:GunInfo=guns[body.current_gun_type]
	
	if not info:
		return
	
	$"../ik_targets/AnimationPlayer".play("shot")
	
	cool_down = info.fire_rate
	
	$"../muzle".look_at(Player.player.global_position)
	$"../muzle".rotation.y = PI
	
	var spwn_effect : Node3D = info.projectile_info.spawn_effect.instantiate()
	muzle.add_child(spwn_effect)
	spwn_effect.transform = muzle.transform
	
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
			

var state : Callable = process_idle
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

func on_death() -> void:
	state = func(delta:float):return
	body.queue_free()

@onready var stats : Stats = $"../Stats"

var sniper_timer : Timer
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
	
	sniper_timer = Timer.new()
	add_child(sniper_timer)
	
	stats.dead.connect(on_death)
	

func process_folow_player(delta:float) -> void:
	
	navegator.is_navegating = true
	
	navegator.target_position = Player.player.global_position
	
	if navegator.is_navegating:
		navegator.look_target =  Navegator.LookTarget.DIRECTION
		animation_tree.set("parameters/Transition/transition_request","walk")
	else:
		navegator.look_target =  Navegator.LookTarget.TARGET
		animation_tree.set("parameters/Transition/transition_request","idle")
	
	state = calculate_next_state()

func process_run_away_from_player(delta:float) -> void:
	
	navegator.is_navegating = true
	
	navegator.target_position = body.global_position.direction_to(Player.player.global_position) * -100.0
	
	navegator.look_target =  Navegator.LookTarget.TARGET
	animation_tree.set("parameters/Transition/transition_request","walk")
	
	state = calculate_next_state()


var sniping : bool = false
func process_sniper(delta:float) -> void:
	if sniping:
		return
	sniping = true
	
	navegator.is_navegating = false
	
	navegator.target_position = calculate_target_future_point(Player.player.global_position,Player.player.velocity,1.0,1.0)
	
	navegator.look_target =  Navegator.LookTarget.TARGET
	animation_tree.set("parameters/Transition/transition_request","idle")
	
	$"../muzle/lazer".visible = true
	
	sniper_timer.start(1.0)
	await sniper_timer.timeout
	
	shot()
	
	$"../muzle/lazer".visible = false
	
	sniper_timer.start(1.0)
	await sniper_timer.timeout
	
	sniping = false
	
	state = calculate_next_state()
	
	
	

func process_shot(delta:float) -> void:
	
	navegator.is_navegating = false
	
	navegator.target_position = Player.player.global_position
	
	navegator.look_target =  Navegator.LookTarget.TARGET
	animation_tree.set("parameters/Transition/transition_request","idle")
	
	if cool_down <= 0 and reload_time <= 0:
		shot()
	
	state = calculate_next_state()

func process_idle(delta:float) -> void:
	
	navegator.look_target =  Navegator.LookTarget.NONE
	animation_tree.set("parameters/Transition/transition_request","idle")
	navegator.is_navegating = false
	
	if is_player_visible:
		state = calculate_next_state()

func calculate_next_state() -> Callable:
	
	if not Player.player:
		return process_idle
	
	var distance : float = body.global_position.distance_to(Player.player.global_position)
	
	if state == process_folow_player and distance > desired_distances[body.current_gun_type].y:
		return process_folow_player
	elif distance > desired_distances[body.current_gun_type].x and distance < desired_distances[body.current_gun_type].z:
		if body.current_gun_type != GenericEnemyModel.GunType.SNIPER:
			return process_shot
		else:
			return process_sniper
	elif distance < desired_distances[body.current_gun_type].y:
		return process_run_away_from_player
	elif distance > desired_distances[body.current_gun_type].z:
		return process_folow_player
	
	
	return process_idle


func _physics_process(delta: float) -> void:
	if in_combat and Player.player:
		
		reload_time -= delta
		cool_down -= delta
		
		
		state.call(delta)
		
		
