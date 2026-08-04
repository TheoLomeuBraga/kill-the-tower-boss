extends ColorRect
class_name VignetteEffect

@export var vignette_color : Color :
	set(value):
		vignette_color = value
		var mat : ShaderMaterial = material
		mat.set_shader_parameter("color_b",vignette_color)


@export var outer_radius : float :
	set(value):
		outer_radius = value
		var mat : ShaderMaterial = material
		mat.set_shader_parameter("outer_radius",value)


func _process(delta: float) -> void:
	vignette_color.a = move_toward(vignette_color.a,0.0,delta*2)
	outer_radius = move_toward(outer_radius,1.5,delta*2)
