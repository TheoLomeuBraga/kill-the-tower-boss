extends Panel

func get_time() -> String:
	return str(floor(SceneManager.time_since_map_loaded*100)/100)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("level_menu"):
		visible = not visible
	
	if not visible:
		return
	
	$Label.text = ""
	if EndMissionCamera.current_end_camera:
		$Label.text += EndMissionCamera.current_end_camera.mission_name + "\n"
	
	$Label.text = tr("time: ") + str(get_time())
