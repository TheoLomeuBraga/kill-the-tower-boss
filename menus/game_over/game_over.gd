extends Control
class_name GameOver

var change_mouse : bool = true

var gameover_vfx_progress : float = 0.0

func _input(event: InputEvent) -> void:
	
	if not change_mouse:
		return
	change_mouse = false
	
	if visible:
		Input.mouse_mode = Input.MouseMode.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MouseMode.MOUSE_MODE_CAPTURED

func gameover() -> void:
	
	if visible:
		return
	
	visible = true
	change_mouse = true
	
	gameover_vfx_progress = 0.0
	

func _process(delta: float) -> void:
	var sm : ShaderMaterial = $ColorRect.material
	gameover_vfx_progress += delta / 2.0
	sm.set_shader_parameter("gameover_progres",gameover_vfx_progress)

func respawn() -> void:
	SceneManager.reload()
	PersistenceManager.load_state()

func _ready() -> void:
	visible = false
