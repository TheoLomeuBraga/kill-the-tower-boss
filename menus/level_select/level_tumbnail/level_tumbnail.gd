extends HBoxContainer

@export var texture : Texture
@export var level_name : String
@export_file_path("*.tscn") var level_file : String
@export var guns : Array[GunInfo]

func load_level() -> void:
	
	SaveManager.save_name = SaveManager.get_avaliable_save_name()
	PersistenceManager.clean()
	SaveManager.clean()
	
	SaveManager.game_data["current_level"] = level_file
	SceneManager.load_map(level_file)
	LevelSelectGunGiver.guns = guns.duplicate()

func focus() -> void:
	$VBoxContainer/Button.grab_focus()

func this_has_focus() -> bool:
	return $VBoxContainer/Button.has_focus()

func enshure_visible() -> void:
	var parent : ScrollContainer = get_parent().get_parent()
	if !parent:
		return
	parent.ensure_control_visible(self)

func _ready() -> void:
	
	$VBoxContainer/Button.focus_entered.connect(enshure_visible)
	
	print(SceneManager.scenes_visited_history)
	
	if SceneManager.scenes_visited_history.has(level_file):
		$VBoxContainer/map_name.text = level_name
		$VBoxContainer/Button.pressed.connect(load_level)
		$TextureRect.texture = texture
	else:
		$VBoxContainer/map_name.text = "lockef"
		$VBoxContainer/Button.disabled = true
		$VBoxContainer/Button.text = tr("locked")
		$TextureRect.texture = load("res://icons/ui/locked.png")
		
