extends Control

signal ended()

func _ready() -> void:
	visible = false

func get_time() -> String:
	return str(floor(SceneManager.time_since_map_loaded*100)/100)

func end() -> void:
	visible = true
	if EndMissionCamera.current_end_camera:
		EndMissionCamera.current_end_camera.current = true
		$name.text = EndMissionCamera.current_end_camera.mission_name
	
	if Player.player:
		Player.player.queue_free()
	
	$time.text = tr("time: ") + str(get_time())
	 

var was_pressed : bool = true
func _process(delta: float) -> void:
	if not visible:
		return
	
	if not was_pressed and Input.is_anything_pressed():
		ended.emit()
		visible = false
	was_pressed = Input.is_anything_pressed()
