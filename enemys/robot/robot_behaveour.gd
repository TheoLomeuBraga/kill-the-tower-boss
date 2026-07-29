extends Node

static var rng : RandomNumberGenerator = RandomNumberGenerator.new()

@onready var robot_animation_simplefier : RobotAnimationSimplefier = $"../RobotAnimationSimplefier"
@onready var navegator : Navegator = $"../Navegator"

@onready var visualizer : RayCast3D = $"../player_visualizer"
@onready var stats : Stats = $"../Stats"

@onready var body : CharacterBody3D = $".."

@onready var look_target : Node3D = $"../look_target"

@export var desired_distances : Vector3 = Vector3(3.0,15,20)

@export var muzle_minigun : Node3D
@export var muzle_rocket_aluncher : Node3D

@export var minigun_info : GunInfo
@export var rocket_aluncher_info : GunInfo

var gun_timer : Timer

var is_player_visible : bool = false
func check_player_visibility() -> bool:
	is_player_visible = false
	
	visualizer.look_at(Player.player.global_position)
	visualizer.force_raycast_update()
	if visualizer.is_colliding() and visualizer.get_collider() == Player.player:
		is_player_visible = true
	
	return is_player_visible

var state : Callable = idle_state
var view_timer : Timer

func none_state(delta:float) -> void:
	pass

func idle_state(delta:float) -> void:
	navegator.is_navegating = false
	if is_player_visible:
		state = folow_state

func decide_state(delta:float) -> void:
	
	var dist_player : float = body.global_position.distance_to(Player.player.global_position)
	
	if dist_player < desired_distances.x:
		state = stomp_state
	elif dist_player > desired_distances.x and dist_player < desired_distances.z:
		state = shot_state
	elif dist_player > desired_distances.z:
		state = folow_state

func folow_state(delta:float) -> void:
	navegator.look_target = Navegator.LookTarget.DIRECTION
	navegator.target_position = Player.player.global_position
	navegator.is_navegating = true
	robot_animation_simplefier.state = RobotAnimationSimplefier.States.WALK
	
	
	if body.global_position.distance_to(Player.player.global_position) < desired_distances.y:
		state = decide_state



func stomp_state(delta:float) -> void:
	state = none_state
	
	robot_animation_simplefier.state = RobotAnimationSimplefier.States.IDLE
	gun_timer.start(0.05)
	await gun_timer.timeout
	robot_animation_simplefier.state = RobotAnimationSimplefier.States.STOMP
	
	
	gun_timer.start(1.0)
	await gun_timer.timeout
	
	#TODO: add explosion
	
	gun_timer.start(0.5)
	await gun_timer.timeout
	
	state = decide_state

func minigun_state(delta:float) -> void:
	state = none_state
	robot_animation_simplefier.minigun = true
	
	gun_timer.start(1.0)
	
	await gun_timer.timeout
	
	state = decide_state

func rocket_launcher_state(delta:float) -> void:
	state = none_state
	robot_animation_simplefier.shot_rocket = true
	
	gun_timer.start(2.0)
	
	await gun_timer.timeout
	
	state = decide_state

func shot_state(delta:float) -> void:
	navegator.look_target = Navegator.LookTarget.NONE
	navegator.target_position = Player.player.global_position
	navegator.is_navegating = false
	robot_animation_simplefier.state = RobotAnimationSimplefier.States.SHOT
	
	var wepon_selection : int = rng.randi_range(0,1)
	match wepon_selection:
		0:
			state = minigun_state
		1:
			state = rocket_launcher_state

func vunerable_state(delta:float) -> void:
	pass

func die() -> void:
	state = none_state
	
	queue_free()





func _ready() -> void:
	view_timer = Timer.new()
	add_child(view_timer)
	view_timer.autostart = true
	view_timer.one_shot = false
	view_timer.start()
	view_timer.wait_time = rng.randf_range(0.4,0.8)
	view_timer.timeout.connect(check_player_visibility)
	
	stats.dead.connect(die)
	
	visualizer.add_exception(body)
	
	gun_timer = Timer.new()
	add_child(gun_timer)
	

func _physics_process(delta: float) -> void:
	state.call(delta)

func _process(delta: float) -> void:
	look_target.global_position = Player.player.global_position
