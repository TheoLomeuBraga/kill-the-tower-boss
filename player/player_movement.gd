extends Node
class_name PlayerMovement

@onready var body : CharacterBody3D = $".."


var estate : Callable = air_estate

var jump_recently : float = 0.0
var floor_recently : float = 0.0

@export_category("geral")
@export var camera : Camera3D

@export var model : PlayerModel

@export var forgiveness_time : float = 0.2

@export var jump_power : float = 4.0

func try_jump() -> void:
	if jump_recently > 0.0 and floor_recently > 0.0:
		body.velocity.y = jump_power

@export_category("grapple estate")

@export var grapple_length : float = 2.0
@export var grapple_range : float = 10.0
@export var grapple_stffness : float = 10.0
@export var grapple_damping : float = 1.0
@export var grapple_raycast : RayCast3D
var grapple_place : Vector3

func launch_grapple() -> void:
	if grapple_raycast.is_colliding():
		grapple_place = grapple_raycast.get_collision_point()
		estate = grapple_estate

func grapple_estate(delta : float) -> void:
	
	body.velocity.y -= gravity * delta
	
	var t_dir : Vector3 = body.global_position.direction_to(grapple_place)
	var t_dis : float = body.global_position.distance_to(grapple_place)
	
	var displacement : float = t_dis - grapple_length
	
	var force : Vector3 = Vector3.ZERO
	
	if displacement > 0.0 and t_dis < grapple_range:
		var sf_magnetude : float = grapple_stffness * displacement
		var sf : Vector3 = t_dir * sf_magnetude
		
		var vel_dot : float = body.velocity.dot(t_dir)
		var danping : Vector3 = -grapple_damping * vel_dot * t_dir
		
		force = sf + danping
	
	
	var input_dir : Vector3 = body.basis * Vector3(Input.get_axis("left","right"),0.0,Input.get_axis("foward","back")).normalized()
	
	body.velocity += force * delta
	
	if not Input.is_action_pressed("shot"):
		estate = air_estate

@export_category("air estate")

@export var gravity : float = 12.0

func air_estate(delta : float) -> void:
	
	body.velocity.y -= gravity * delta
	
	if body.is_on_floor():
		estate = floor_estate
	
	try_jump()

@export_category("floor estate")

@export var speed : float = 5.0
@export var floor_friction : float = 100.0

func floor_estate(delta : float) -> void:
	
	var input_dir : Vector3 = body.basis * Vector3(Input.get_axis("left","right"),0.0,Input.get_axis("foward","back")).normalized()
	var vec_speed : Vector3 = input_dir * speed
	
	body.velocity = body.velocity.move_toward(vec_speed,delta * floor_friction)
	
	if not body.is_on_floor():
		estate = air_estate
	
	try_jump()
	
@export_category("camera")

@export var mouse_sensitivity : float = 0.01
@export var joystick_sensitivity : float = 12.0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mm : InputEventMouseMotion = event
		body.rotation.y -= mouse_sensitivity * mm.screen_relative.x
		camera.rotation.x -= mouse_sensitivity * mm.screen_relative.y

func camera_process(delta : float) -> void:
	
	body.rotation.y += delta * Input.get_axis("look_right","look_left")
	camera.rotation.x += delta * Input.get_axis("look_down","look_up")
	
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x,-90,90)



func _ready() -> void:
	model.set_gun("pistol")
	if grapple_raycast != null:
		grapple_raycast.add_exception(body)



func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("jump"):
		jump_recently = forgiveness_time
	
	if body.is_on_floor():
		floor_recently = forgiveness_time
	
	camera_process(delta)
	estate.call(delta)
	body.move_and_slide()
	
	jump_recently -= delta
	floor_recently -= delta
	
	
	#debug
	'''
	if Input.is_action_just_pressed("shot"):
		launch_grapple()
	'''
