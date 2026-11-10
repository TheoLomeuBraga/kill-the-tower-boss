extends HBoxContainer

@export var texture : Texture
@export var level_name : String
@export_file_path("*.tscn") var level_file : String

func load_level() -> void:
	SceneManager.load_map(level_file)

func focus() -> void:
	$VBoxContainer/Button.grab_focus()

func _ready() -> void:
	
	await  get_tree().process_frame
	
	
	if SceneManager.scenes_visited_history.has(level_file):
		$VBoxContainer/map_name.text = level_name
		$VBoxContainer/Button.pressed.connect(load_level)
		$TextureRect.texture = texture
	else:
		$VBoxContainer/map_name.text = "lockef"
		$VBoxContainer/Button.disabled = true
		$VBoxContainer/Button.text = tr("locked")
		$TextureRect.texture = load("res://icons/ui/locked.png")
		
