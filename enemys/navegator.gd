extends NavigationAgent3D
class_name Navegator

static var rng : RandomNumberGenerator = RandomNumberGenerator.new()

var body : CharacterBody3D
var timer : Timer = Timer.new()

var is_navegating : bool = false
var desired_velocity : Vector3 = Vector3.ZERO
var next_path_position : Vector3 = Vector3.ZERO

var look_reference : Node3D = Node3D.new()

@export_category("navegator")
enum LookTarget {NONE,DIRECTION,TARGET}
@export var look_target : LookTarget = LookTarget.DIRECTION
@export var rotation_speed : float = 3.0

@export_category("ground")
@export var speed : float = 2.0
@export var friction : float = 100.0

@export_category("air")
@export var gravity : float = -9.0

func recalculate_route() -> void:
	timer.start(rng.randf_range(0.5,1.0))
	next_path_position = get_next_path_position()

func _ready() -> void:
	
	body = get_parent()
	add_child(timer)
	timer.timeout.connect(recalculate_route)
	timer.start(rng.randf_range(0.5,1.0))
	
	recalculate_route()
	
	await get_tree().process_frame
	body.add_child(look_reference)
	

func process_look_dir(delta: float) -> void: #TODO
	match look_target:
		LookTarget.DIRECTION:
			look_reference.look_at(next_path_position)
		LookTarget.TARGET:
			look_reference.look_at(target_position)
	
	look_reference.rotation.y += PI
	
	if look_target != LookTarget.NONE:
		body.global_rotation.y = rotate_toward(body.global_rotation.y,look_reference.global_rotation.y,rotation_speed*delta)
		

func _physics_process(delta: float) -> void:
	
	if is_navegating:
		desired_velocity = (next_path_position - body.global_position).normalized() * speed
	else:
		desired_velocity = Vector3.ZERO
	
	if not body.is_on_floor():
		body.velocity.y += gravity * delta
	
	body.velocity.x = move_toward(body.velocity.x,desired_velocity.x,delta*friction)
	body.velocity.z = move_toward(body.velocity.z,desired_velocity.z,delta*friction)
	body.move_and_slide()
	
	process_look_dir(delta)
