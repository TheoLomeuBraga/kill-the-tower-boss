extends Node
class_name ApplyDamageVfx

static var base_material : ShaderMaterial = load("res://vfx/damage/damage_material.tres")
var material : ShaderMaterial

func apply_overlay(n : Node) -> void:
	if n is GeometryInstance3D:
		var gi : GeometryInstance3D = n
		gi.material_overlay = material
	
	for c : Node in n.get_children():
		apply_overlay(c)

func _ready() -> void:
	material = base_material.duplicate()
	
	for c : Node in get_parent().get_children():
		if c is Stats:
			var s : Stats = c
			s.damaged.connect(play_hit_fx)
	
	apply_overlay(get_parent())

func play_hit_fx(i:int=0) -> void:
	material.set_shader_parameter("fresnel_power",1.0)

func _process(delta: float) -> void:
	material.set_shader_parameter("fresnel_power",material.get_shader_parameter("fresnel_power") - (delta * 5.0))
