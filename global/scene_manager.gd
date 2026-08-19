extends Node

@export var load_image : Texture

var loaded_map : Node
var load_progress : float = 0.0
var loading : bool = false
signal loaded()

func load_map(map_name:String) -> void:
	
	$Control/TextureRect.texture = load_image
	
	if loading:
		return
	loading = true
	$Control.visible = true
	
	if loaded_map != null:
		loaded_map.queue_free()
	
	ResourceLoader.load_threaded_request(map_name)
	
	await get_tree().process_frame
	
	while true:
		await get_tree().process_frame
		var progress : Array[float] = []
		var status : ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(map_name,progress)
		load_progress = progress[0]
		
		if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			
			loaded_map = ResourceLoader.load_threaded_get(map_name).instantiate()
			add_child(loaded_map)
			loading = false
			loaded.emit()
			$Control.visible = false
			
			break

const main_scene_file : String = "res://main.tscn"

func reload()-> void:
	load_map(loaded_map.scene_file_path)

@export_file("*.tscn") var main_scene : String
func _ready() -> void:
	
	if get_tree().current_scene.scene_file_path != main_scene_file:
		main_scene = get_tree().current_scene.scene_file_path
		get_tree().change_scene_to_file(main_scene_file)
	
	load_map(main_scene)
	
