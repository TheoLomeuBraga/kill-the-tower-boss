extends MeshInstance3D

var door : DoorManager
var target_pos_x : float = 0.0

func _physics_process(delta: float) -> void:
	position.x = move_toward(position.x,target_pos_x,delta*2)

func on_state_change(value:bool) -> void:
	if value:
		target_pos_x = 1.2
	else:
		target_pos_x = 0

func _ready() -> void:
	door = get_parent()
	door.door_open_changed.connect(on_state_change)
