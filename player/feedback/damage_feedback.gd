extends ColorRect
class_name DamageFeedback

@export var stats : Stats
var body : CharacterBody3D

func _ready() -> void:
	body = stats.get_parent()
