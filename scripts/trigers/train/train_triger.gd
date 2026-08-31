extends CharacterBody3D
class_name TrainTriger

@export var active : bool = false

enum MovementModes {LINEAR,LOOP,PING_PONG}
@export var movement_mode : MovementModes

@export var speed : float = 5.0
@export var rotation_speed : float = 4.0

var rails : Array[TrainRail]
var target_rail : int = 0

var time_to_next : float = 0.0

func _ready() -> void:
	motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
	slide_on_ceiling = false
	floor_stop_on_slope = false
	floor_block_on_wall = false
	
	for n : Node in get_children():
		if n is TrainRail:
			rails.push_back(n)
	
	global_position = rails[target_rail].global_position
	global_rotation = rails[target_rail].global_rotation
	

func mt_next(delta: float) -> void:
	global_position = global_position.move_toward(rails[target_rail].global_position,delta*speed)
	global_rotation = global_rotation.move_toward(rails[target_rail].global_rotation,delta*rotation_speed)

var ping_pong_reversed:bool = false

func _physics_process(delta: float) -> void:
	
	if not rails.size():
		return
	
	time_to_next -= delta
	
	if time_to_next > 0:
		return
	
	
	match movement_mode:
			MovementModes.LINEAR:
				mt_next(delta)
			MovementModes.LOOP:
				if active:
					mt_next(delta)
			MovementModes.PING_PONG:
				if active:
					mt_next(delta)
					
	
	
	if global_position == rails[target_rail].global_position:
		
		time_to_next = rails[target_rail].interuption_time
		
		match movement_mode:
			MovementModes.LINEAR:
				if active:
					target_rail = clamp(target_rail+1,0,rails.size()-1)
				else:
					target_rail = clamp(target_rail-1,0,rails.size()-1)
			MovementModes.LOOP:
				if active:
					target_rail = (target_rail+1)%rails.size()
			MovementModes.PING_PONG:
				if active:
					if not ping_pong_reversed:
						target_rail = clamp(target_rail+1,0,rails.size()-1)
						if target_rail==rails.size()-1:
							ping_pong_reversed=true
					else:
						target_rail = clamp(target_rail-1,0,rails.size()-1)
						if target_rail==0:
							ping_pong_reversed=false
		
	

func triger() -> void:
	active = not active
