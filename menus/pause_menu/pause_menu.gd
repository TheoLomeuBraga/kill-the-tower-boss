extends Control
class_name PauseMenu

func pause_unpause() -> void:
	change_mouse = true
	visible = not visible
	get_tree().paused = not get_tree().paused
	if not get_tree().paused:
		$SettingsMenu.on_close.emit()

func _ready() -> void:
	visible = false
	
	$Panel/VBoxContainer/continue.pressed.connect(pause_unpause)
	$Panel/VBoxContainer/settings.pressed.connect(func():$SettingsMenu.visible=true)
	$SettingsMenu.on_close.connect(func():$SettingsMenu.visible=false)
	$Panel/VBoxContainer/quit_game.pressed.connect(get_tree().quit)

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
	$Panel.visible = not $SettingsMenu.visible
	if Input.is_action_just_pressed("pause"):
		pause_unpause()
