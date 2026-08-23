extends Node

func on_setting_change(name:String,value:Variant) -> void:
	match name:
		"audio_volume":
			var idx : int = AudioServer.get_bus_index("Master")
			AudioServer.set_bus_volume_linear(idx,float(value)/100.0)
		"audio_volume_sfx":
			var idx : int = AudioServer.get_bus_index("SFX")
			AudioServer.set_bus_volume_linear(idx,float(value)/100.0)
		"audio_volume_music":
			var idx : int = AudioServer.get_bus_index("Music")
			AudioServer.set_bus_volume_linear(idx,float(value)/100.0)
		"audio_volume_dialogue":
			var idx : int = AudioServer.get_bus_index("Dialogue")
			AudioServer.set_bus_volume_linear(idx,float(value)/100.0)
		"video_full_screen":
			if value:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		"controller_deadzone_left":
			for key:String in ["foward","back","left","right"]:
				InputMap.action_set_deadzone(key,value)
		"controller_deadzone_right":
			for key:String in ["look_up","look_down","look_left","look_right"]:
				InputMap.action_set_deadzone(key,value)

func _ready() -> void:
	Settings.on_setting_change.connect(on_setting_change) 
