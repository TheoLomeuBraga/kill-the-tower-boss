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

func _ready() -> void:
	Settings.on_setting_change.connect(on_setting_change) 
