extends Node
class_name DroneBehavior

@onready var body : CharacterBody3D = $".."

@onready var visualizer : RayCast3D = $"../player_visualizer"
@onready var stats : Stats = $"../Stats"

@onready var navegator : Navegator = $"../Navegator"

@onready var rotation_reference : Node3D = $"../rotation_reference"

static var rng : RandomNumberGenerator = RandomNumberGenerator.new()

@export var desired_distances : Vector3

@onready var muzles : Array[Node3D] = [$"../muzle_r",$"../muzle_l"]

@export var gun_info : GunInfo

var is_player_visible : bool = false
func check_player_visibility() -> bool:
	is_player_visible = false
	
	visualizer.look_at(Player.player.global_position)
	visualizer.force_raycast_update()
	if visualizer.is_colliding() and visualizer.get_collider() == Player.player:
		is_player_visible = true
	
	return is_player_visible

var atack_animation_progresion : float :
	set(value):
		atack_animation_progresion = value
		$"../AnimationTree".set("parameters/Blend2/blend_amount",value)

var state : Callable = idle_state

func get_player_distance() -> float:
	return body.global_position.distance_to(Player.player.global_position)

func die_state() -> void:
	state = func(delta:float): return
	body.queue_free()

func idle_state(delta:float) -> void:
	navegator.is_navegating = false
	if is_player_visible:
		state = folow_state

func folow_state(delta:float) -> void:
	navegator.target_position = Player.player.global_position + (Vector3.UP * 2.0)
	navegator.is_navegating = true
	
	if get_player_distance() < desired_distances.y:
		state = atack_state
	
	atack_animation_progresion = move_toward(atack_animation_progresion,0.0,delta+2.0)

var current_muzle : int = 0
var cool_down : float = 0.0

func shot() -> void:
	
	current_muzle = (current_muzle+1) % 2
	var muzle : Node3D = muzles[current_muzle]
	
	if not gun_info:
		return
	
	cool_down = gun_info.fire_rate
	
	muzle.look_at(Player.player.global_position)
	muzle.rotation.y = PI
	
	var spwn_effect : Node3D = gun_info.projectile_info.spawn_effect.instantiate()
	muzle.add_child(spwn_effect)
	spwn_effect.transform = muzle.transform
	
	for i : int in gun_info.bullets_per_shot:
		
		var projectile : ProjectBehavior = ProjectBehavior.new()
		add_child(projectile)
		projectile.global_position = muzle.global_position
		projectile.muzle_position = muzle.global_position
		
		projectile.target_position = muzle.global_basis.z * -100.0
		
		projectile.global_rotation = muzle.global_rotation
		
		var spread : float = gun_info.spread
		var vec_spread : Vector3 = Vector3(rng.randf_range(-1.0,1.0),rng.randf_range(-1.0,1.0),rng.randf_range(-1.0,1.0))
		if vec_spread.length() > 1.0:
			vec_spread = vec_spread.normalized()
		vec_spread /= 1.0
		var aditional_rot : Vector3 = vec_spread * spread
		projectile.rotate_x(aditional_rot.x)
		projectile.rotate_y(aditional_rot.y)
		projectile.rotate_z(aditional_rot.z)
		
		projectile.data = gun_info.projectile_info
		projectile.start()
	



func atack_state(delta:float) -> void:
	navegator.is_navegating = false
	
	atack_animation_progresion = move_toward(atack_animation_progresion,1.0,delta+2.0)
	
	if get_player_distance() > desired_distances.z:
		state = folow_state
	
	if cool_down < 0.0:
		shot()

func dash_state(delta:float) -> void:
	navegator.is_navegating = false

var view_timer : Timer

func _ready() -> void:
	view_timer = Timer.new()
	add_child(view_timer)
	view_timer.autostart = true
	view_timer.one_shot = false
	view_timer.start()
	view_timer.wait_time = rng.randf_range(0.4,0.8)
	view_timer.timeout.connect(check_player_visibility)
	
	stats.dead.connect(die_state)

func _physics_process(delta: float) -> void:
	if Player.player:
		
		cool_down -= delta
		
		state.call(delta)
		
		rotation_reference.look_at(Player.player.global_position)
		body.global_rotation.x = rotate_toward(body.global_rotation.x,-rotation_reference.global_rotation.x,5.0*delta)
		body.global_rotation.y = rotate_toward(body.global_rotation.y,rotation_reference.global_rotation.y + PI,5.0*delta)
