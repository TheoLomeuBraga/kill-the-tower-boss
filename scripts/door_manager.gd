extends Node3D
class_name DoorManager

signal door_open_changed(bool)
var is_open : bool = false :
	set(value):
		
		if value != is_open:
			door_open_changed.emit(value)
		
		is_open = value

@export var proximity_area : Area3D
var is_player_near:bool = false

enum DoorStates{OPEN,LOCKED,UNLOCKED}
@export var states : Array[DoorStates] = [DoorStates.LOCKED,DoorStates.UNLOCKED]
var current_state_id : int = 0

func on_enter(body:Node3D) -> void:
	if body is Player:
		is_player_near = true

func on_exit(body:Node3D) -> void:
	if body is Player:
		is_player_near = false

func _ready() -> void:
	if proximity_area:
		proximity_area.body_entered.connect(on_enter)
		proximity_area.body_exited.connect(on_exit)

func triger() -> void:
	if states.size() == 0:
		return
	current_state_id = (current_state_id+1) % states.size()

func _physics_process(delta: float) -> void:
	
	if states.size() == 0:
		return
	
	
	var current_state : DoorStates = states[current_state_id]
	
	match current_state:
		DoorStates.OPEN:
			is_open = true
		DoorStates.LOCKED:
			is_open = false
		DoorStates.UNLOCKED:
			is_open = is_player_near
		
	
