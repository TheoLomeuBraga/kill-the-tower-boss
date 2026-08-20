extends Control
class_name GameOver

var change_mouse : bool = true

func _input(event: InputEvent) -> void:
	
	if not change_mouse:
		return
	change_mouse = false
	
	if visible:
		Input.mouse_mode = Input.MouseMode.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MouseMode.MOUSE_MODE_CAPTURED

func gameover() -> void:
	visible = true
	change_mouse = true

func respawn() -> void:
	SceneManager.reload()
	PersistenceManager.load_state()

func _ready() -> void:
	visible = false
