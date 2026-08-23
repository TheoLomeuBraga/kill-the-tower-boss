extends Panel
class_name CheckPointIndicator

@onready var mat : ShaderMaterial = material
@export var transparency : float = 0.0 :
	set(value):
		transparency = value
		if mat:
			mat.set_shader_parameter("transparency",transparency)

func _ready() -> void:
	await get_tree().process_frame
	PersistenceManager.on_save.connect(func():transparency=1.0)

func _process(delta: float) -> void:
	transparency = move_toward(transparency,0.0,delta)
