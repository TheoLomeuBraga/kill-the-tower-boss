extends Control
class_name PauseMenu

func _ready() -> void:
	visible = false

var change_mouse : bool = true

func _input(event: InputEvent) -> void:
	
	if not change_mouse:
		return
	change_mouse = false
	
	if visible:
		Input.mouse_mode = Input.MouseMode.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MouseMode.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		change_mouse = true
		visible = not visible
		get_tree().paused = not get_tree().paused
