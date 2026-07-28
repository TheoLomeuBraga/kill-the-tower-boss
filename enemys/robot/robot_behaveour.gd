extends Node

static var rng : RandomNumberGenerator = RandomNumberGenerator.new()

@onready var robot_animation_simplefier : RobotAnimationSimplefier = $"../RobotAnimationSimplefier"
@onready var navegator : Navegator = $"../Navegator"

@onready var visualizer : RayCast3D = $"../player_visualizer"
@onready var stats : Stats = $"../Stats"

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

func idle_state(delta:float) -> void:
	navegator.is_navegating = false
	if is_player_visible:
		state = folow_state

func folow_state(delta:float) -> void:
	pass

func shot_state(delta:float) -> void:
	pass

func vunerable_state(delta:float) -> void:
	pass

func death_state(delta:float) -> void:
	pass

func die() -> void:
	state = death_state



func _ready() -> void:
	view_timer = Timer.new()
	add_child(view_timer)
	view_timer.autostart = true
	view_timer.one_shot = false
	view_timer.start()
	view_timer.wait_time = rng.randf_range(0.4,0.8)
	view_timer.timeout.connect(check_player_visibility)
	
	stats.dead.connect(die)
	

func _physics_process(delta: float) -> void:
	state.call(delta)
