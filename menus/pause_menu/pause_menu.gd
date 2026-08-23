extends Control
class_name PauseMenu

var pausable : bool = true

var change_mouse : bool = true
func _input(event: InputEvent) -> void:
	
	if not change_mouse:
		return
	change_mouse = false
	
	if visible:
		Input.mouse_mode = Input.MouseMode.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MouseMode.MOUSE_MODE_CAPTURED

func pause_unpause() -> void:
	
	if not pausable:
		return
	
	change_mouse = true
	visible = not visible
	get_tree().paused = not get_tree().paused
	if not get_tree().paused:
		$SettingsMenu.on_close.emit()
		$SettingsMenu.change_type(SettingsMenu.SettingsTypes.MENU)
	else:
		$Panel/VBoxContainer/continue.grab_focus()

func _ready() -> void:
	visible = false
	
	$Panel/VBoxContainer/continue.pressed.connect(pause_unpause)
	$Panel/VBoxContainer/settings.pressed.connect(func():$SettingsMenu.visible=true)
	$Panel/VBoxContainer/settings.pressed.connect(func():$SettingsMenu.focus())
	
	$SettingsMenu.on_close.connect(func():$SettingsMenu.visible=false)
	$SettingsMenu.on_close.connect(func():$Panel/VBoxContainer/continue.grab_focus())
	
	$Panel/VBoxContainer/quit_game.pressed.connect(get_tree().quit)
	
	$"../Stats".dead.connect(func():pausable=false)




func _process(delta: float) -> void:
	$Panel.visible = not $SettingsMenu.visible
	if Input.is_action_just_pressed("pause"):
		pause_unpause()
		
		if get_tree().paused:
			$SettingsMenu.on_close.emit()
			$Panel/VBoxContainer/continue.grab_focus()
