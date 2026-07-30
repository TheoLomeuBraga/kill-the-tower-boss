extends Node

static var rng : RandomNumberGenerator = RandomNumberGenerator.new()

@onready var robot_animation_simplefier : RobotAnimationSimplefier = $"../RobotAnimationSimplefier"
@onready var navegator : Navegator = $"../Navegator"

@onready var weak_spots : Array[CollisionShape3D] = [$"../heat_sinc_1",$"../heat_sinc_2"]

@onready var visualizer : RayCast3D = $"../player_visualizer"
@onready var stats : Stats = $"../Stats"

@onready var body : CharacterBody3D = $".."

@onready var look_target : Node3D = $"../look_target"

@export var desired_distances : Vector3 = Vector3(3.0,15,20)

@export var muzle_minigun : Node3D
@export var muzle_rocket_aluncher : Node3D

const death_explosion : PackedScene = preload("res://vfx/particles/generic_explosion.tscn")

@export var minigun_info : ProjectileInfo
@export var rocket_aluncher_info : ProjectileInfo
@export var stomp_info : ExplosionInfo

@export var max_stamina : float = 100.0
@export var stamina_degradation_speed : float = 5.0
var stamina : float = max_stamina

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
	
	if stamina <= 0:
		state = vunerable_state
	elif dist_player < desired_distances.x:
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
	
	
	gun_timer.start(0.5)
	await gun_timer.timeout
	
	var explosion : ExplosionBehavior = ExplosionBehavior.new()
	explosion.data = stomp_info
	add_child(explosion)
	explosion.global_position = body.global_position
	
	gun_timer.start(1.0)
	await gun_timer.timeout
	
	state = decide_state

func shot_minigun() -> void:
	
	muzle_minigun.look_at(Player.player.global_position)
	
	var bullet : ProjectBehavior = ProjectBehavior.new()
	bullet.data = minigun_info
	body.get_parent().add_child(bullet)
	bullet.global_transform = muzle_minigun.global_transform
	bullet.start()
	

func minigun_state(delta:float) -> void:
	
	state = none_state
	
	gun_timer.start(1.0)
	await gun_timer.timeout
	
	robot_animation_simplefier.minigun = true
	
	#gun_timer.start(1.0)
	#await gun_timer.timeout
	
	for i : int in 12:
		shot_minigun()
		gun_timer.start(1.0/12.0)
		await gun_timer.timeout
	
	state = decide_state

func rocket_launcher_state(delta:float) -> void:
	
	state = none_state
	
	gun_timer.start(1.0)
	await gun_timer.timeout
	
	robot_animation_simplefier.shot_rocket = true
	
	gun_timer.start(2.0)
	
	await gun_timer.timeout
	
	state = decide_state

func shot_state(delta:float) -> void:
	navegator.look_target = Navegator.LookTarget.NONE
	navegator.target_position = Player.player.global_position
	navegator.is_navegating = false
	robot_animation_simplefier.state = RobotAnimationSimplefier.States.SHOT
	robot_animation_simplefier.can_recover = false
	
	var wepon_selection : int = rng.randi_range(0,2)
	match wepon_selection:
		0:
			state = minigun_state
		1:
			state = minigun_state
		2:
			state = rocket_launcher_state

func vunerable_state(delta:float) -> void:
	navegator.look_target = Navegator.LookTarget.NONE
	navegator.target_position = Player.player.global_position
	navegator.is_navegating = false
	robot_animation_simplefier.state = RobotAnimationSimplefier.States.VUNERABLE
	
	state = none_state
	
	for c : CollisionShape3D in weak_spots:
		c.disabled = false
	
	
	gun_timer.start(5.0)
	await gun_timer.timeout
	
	robot_animation_simplefier.can_recover = true
	
	for c : CollisionShape3D in weak_spots:
		c.disabled = true
	
	await get_tree().process_frame
	robot_animation_simplefier.can_recover = true
	
	stamina = max_stamina
	state = decide_state

func die() -> void:
	state = none_state
	
	var explosion : Node3D = death_explosion.instantiate()
	body.get_parent().add_child(explosion)
	explosion.global_position = body.global_position
	explosion.global_position.y += 2.0
	
	get_parent().queue_free()



func subtract_stamina(damage:int)  -> void:
	stamina -= damage

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
	
	for c : CollisionShape3D in weak_spots:
		c.disabled = true
	
	stamina = max_stamina
	
	stats.damaged.connect(subtract_stamina)

func _physics_process(delta: float) -> void:
	if state != idle_state:
		stamina -= delta * stamina_degradation_speed
	state.call(delta)

func _process(delta: float) -> void:
	look_target.global_position = Player.player.global_position
