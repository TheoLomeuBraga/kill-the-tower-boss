extends Control

func _input(event: InputEvent) -> void:
	if Input.mouse_mode != Input.MouseMode.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MouseMode.MOUSE_MODE_VISIBLE

func _ready() -> void:
	$ColorRect/Button.pressed.connect(SceneManager.load_map.bind("res://menus/main_menu/main_menu.tscn"))
	$ColorRect/Button.grab_focus()
