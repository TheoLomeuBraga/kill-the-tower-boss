@tool
extends Node3D

var material : StandardMaterial3D

@export var type : GlobalEnums.KeyCards

var sync_data : Dictionary

func set_right_color() -> void:
	match type:
		GlobalEnums.KeyCards.RED:
			material.uv1_offset.y = -(1.0/3.0)*1.0
		GlobalEnums.KeyCards.YELLOW:
			material.uv1_offset.y = -(1.0/3.0)*2.0
		GlobalEnums.KeyCards.BLUE:
			material.uv1_offset.y = -(1.0/3.0)*3.0

func _ready() -> void:
	material = $Cube.get_surface_override_material(1)
	set_right_color()
	
	sync_data["used"] = false
	if not PersistenceManager.has(self):
			PersistenceManager.register(self,sync_data)
	else:
		sync_data = PersistenceManager.get_ref(self)
	
	if sync_data["used"]:
		material.uv1_offset.x=0.5

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		set_right_color()
		


var used:bool=false
var tween : Tween
func triger() -> void:
	if Engine.is_editor_hint() or used:
		return
	used = true
	
	$AudioStreamPlayer3D.play()
	
	sync_data["used"] = true
	
	tween = create_tween()
	tween.tween_property(material, "uv1_offset:x", 0.5, 0.2)
