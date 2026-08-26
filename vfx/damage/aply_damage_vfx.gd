extends Node
class_name ApplyDamageVfx

const base_material : ShaderMaterial = preload("res://vfx/damage/damage_material.tres")
var material : ShaderMaterial : 
	set(value):
		material = value


func apply_overlay(n : Node) -> void:
	if n is GeometryInstance3D:
		var gi : GeometryInstance3D = n
		gi.material_overlay = material
	
	for c : Node in n.get_children():
		apply_overlay(c)


func _ready() -> void:
	material = base_material.duplicate()
	
	apply_overlay(get_parent())
	
	
	

func play_hit_fx(color:Color) -> void:
	if not material:
		return
	
	material.set_shader_parameter("color",color)
	material.set_shader_parameter("fresnel_power",1.0)

func _process(delta: float) -> void:
	material.set_shader_parameter("fresnel_power",material.get_shader_parameter("fresnel_power") - (delta * 5.0))
