extends Node
class_name DroneBehavior

@onready var body : CharacterBody3D = $".."

@onready var visualizer : RayCast3D = $"../player_visualizer"
@onready var stats : Stats = $"../Stats"

@onready var navegator : Navegator = $"../Navegator"

@onready var rotation_reference : Node3D = $"../rotation_reference"

static var rng : RandomNumberGenerator = RandomNumberGenerator.new()

var is_player_visible : bool = false
func check_player_visibility() -> bool:
	is_player_visible = false
	
	visualizer.look_at(Player.player.global_position)
	visualizer.force_raycast_update()
	if visualizer.is_colliding() and visualizer.get_collider() == Player.player:
		is_player_visible = true
	
	return is_player_visible

var state : Callable = idle_state

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

func atack_state(delta:float) -> void:
	navegator.is_navegating = false
	
	

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
		state.call(delta)
		
		rotation_reference.look_at(Player.player.global_position)
		body.global_rotation.x = rotate_toward(body.global_rotation.x,-rotation_reference.global_rotation.x,5.0*delta)
		body.global_rotation.y = rotate_toward(body.global_rotation.y,rotation_reference.global_rotation.y + PI,5.0*delta)
