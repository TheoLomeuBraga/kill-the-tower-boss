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

var master_volume : float = 0.0 :
	set(value):
		var idx : int = AudioServer.get_bus_index("Master")
		AudioServer.set_bus_volume_linear(idx,value)
	get():
		var idx : int = AudioServer.get_bus_index("Master")
		return AudioServer.get_bus_volume_linear(idx)

func gameover() -> void:
	
	if visible:
		return
	
	visible = true
	change_mouse = true
	gameover_vfx_progress = 0.0
	
	$respawn.grab_focus()
	

func _process(delta: float) -> void:
	var sm : ShaderMaterial = $ColorRect.material
	gameover_vfx_progress += delta / 2.0
	sm.set_shader_parameter("gameover_progres",gameover_vfx_progress)
	
	if visible:
		master_volume = move_toward(master_volume,0.0,delta/2.0)

func respawn() -> void:
	SceneManager.reload()
	PersistenceManager.load_state()
	
	var idx : int = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_linear(idx,float(SettingsManager.settings["audio_volume"])/100.0)

func _ready() -> void:
	visible = false
