extends Node

signal on_save()
signal on_change()

const mouse_sensitivity_correction : float = 600.0

var settings : Dictionary = {
	"volume": 80,
	"volume_sfx": 100,
	"volume_music": 100,
	"volume_dialogue": 100,
	
	"sensitivity_mouse": 6.0,
	"sensitivity_joystick": 6.0,
	"fov": 90,
}

func load_state() -> void:
	pass

func save_state() -> void:
	on_save.emit()
	
	#do thing

func change_state(data:Dictionary) -> void:
	#do thing
	
	on_change.emit(settings)
