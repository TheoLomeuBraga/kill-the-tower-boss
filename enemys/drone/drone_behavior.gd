extends Node
class_name DroneBehavior

@onready var body : DroneModel = $".."

@onready var visualizer : RayCast3D = $"../player_visualizer"
@onready var stats : Stats = $"../Stats"

@onready var navegator : Navegator = $"../Navegator"

@onready var rotation_reference : Node3D = $"../rotation_reference"

static var rng : RandomNumberGenerator = RandomNumberGenerator.new()

@export var desired_distances : Vector3

@onready var muzles : Array[Node3D] = [$"../muzle_r",$"../muzle_l"]

@export var gun_info : GunInfo
@export var shot_gun_info : GunInfo

@export var time_betwen_dashes : float = 3.0
@export var time_wile_dashes : float = 0.2

@export var speed : float = 8.0
@export var dash_speed : float = 20.0

@export var shotgun_drone_material : Material

func apply_shotgun_material_overwrride(n : Node) -> void:
	if n is GeometryInstance3D:
		var gi : GeometryInstance3D = n
		gi.material_override = shotgun_drone_material
	
	for c : Node in n.get_children():
		apply_shotgun_material_overwrride(c)

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
	
	navegator.speed = speed
	
	if get_player_distance() < desired_distances.y:
		state = atack_state
	
	atack_animation_progresion = move_toward(atack_animation_progresion,0.0,delta+2.0)

var current_muzle : int = 0
var cool_down : float = 0.0

func shot() -> void:
	
	current_muzle = (current_muzle+1) % 2
	var muzle : Node3D = muzles[current_muzle]
	
	var current_gun : GunInfo = gun_info
	if body.gun_type == DroneModel.GunType.SHOTGUN:
		current_gun = shot_gun_info
	
	if not current_gun:
		return
	
	cool_down = current_gun.fire_rate
	
	muzle.look_at(Player.player.global_position)
	muzle.rotation.y = PI
	
	var spwn_effect : Node3D = current_gun.projectile_info.spawn_effect.instantiate()
	muzle.add_child(spwn_effect)
	spwn_effect.transform = muzle.transform
	
	for i : int in current_gun.bullets_per_shot:
		
		var projectile : ProjectBehavior = ProjectBehavior.new()
		add_child(projectile)
		projectile.global_position = muzle.global_position
		projectile.muzle_position = muzle.global_position
		
		projectile.target_position = muzle.global_basis.z * -100.0
		
		projectile.global_rotation = muzle.global_rotation
		
		var spread : float = current_gun.spread
		var vec_spread : Vector3 = Vector3(rng.randf_range(-1.0,1.0),rng.randf_range(-1.0,1.0),rng.randf_range(-1.0,1.0))
		if vec_spread.length() > 1.0:
			vec_spread = vec_spread.normalized()
		vec_spread /= 1.0
		var aditional_rot : Vector3 = vec_spread * spread
		projectile.rotate_x(aditional_rot.x)
		projectile.rotate_y(aditional_rot.y)
		projectile.rotate_z(aditional_rot.z)
		
		projectile.data = current_gun.projectile_info
		projectile.start()
	

var time_to_dash : float = 3.0
var time_to_stop_dash : float = 0.2

var dash_desired_direction : Vector3

func atack_state(delta:float) -> void:
	navegator.is_navegating = false
	
	atack_animation_progresion = move_toward(atack_animation_progresion,1.0,delta+2.0)
	
	if get_player_distance() > desired_distances.z:
		state = folow_state
	
	if cool_down < 0.0:
		shot()
	
	time_to_dash -= delta
	if time_to_dash <= 0:
		state = dash_state
		time_to_dash = time_betwen_dashes
		time_to_stop_dash = time_wile_dashes
		
		var dash_desired_position : Vector3 = Vector3(rng.randf_range(-1.0,1.0),0.0,rng.randf_range(-1.0,1.0))
		dash_desired_position = dash_desired_position.normalized() * 10
		dash_desired_position += Player.player.global_position
		
		dash_desired_direction = (dash_desired_position - body.global_position)
		dash_desired_direction.y = 0
		dash_desired_direction = dash_desired_direction.normalized()
		

func dash_state(delta:float) -> void:
	navegator.is_navegating = false
	
	time_to_stop_dash -= delta
	
	if time_to_stop_dash <= 0:
		state = atack_state
	
	body.velocity = dash_desired_direction * dash_speed
	

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
	
	if body.gun_type == DroneModel.GunType.SHOTGUN:
		apply_shotgun_material_overwrride(body)

func _physics_process(delta: float) -> void:
	if Player.player:
		
		cool_down -= delta
		
		state.call(delta)
		
		rotation_reference.look_at(Player.player.global_position)
		body.global_rotation.x = rotate_toward(body.global_rotation.x,-rotation_reference.global_rotation.x,5.0*delta)
		body.global_rotation.y = rotate_toward(body.global_rotation.y,rotation_reference.global_rotation.y + PI,5.0*delta)
