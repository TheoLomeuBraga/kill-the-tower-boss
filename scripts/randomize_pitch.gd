extends Node
class_name RandomizePitch


static var rng : RandomNumberGenerator = RandomNumberGenerator.new()
@export var variation_range : Vector2 = Vector2(0.5,1.5)
func _ready() -> void:
	if get_parent() is AudioStreamPlayer:
		get_parent().pitch_scale = rng.randf_range(variation_range.x,variation_range.y)
	
	if get_parent() is AudioStreamPlayer3D:
		get_parent().pitch_scale = rng.randf_range(variation_range.x,variation_range.y)
