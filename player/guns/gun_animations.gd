@tool
extends Node3D
class_name GunAnimations

@onready var gun : Node3D = $gun

@onready var animation_tree : AnimationTree = $AnimationTree

@export_range(0.0,1.0) var walk : float :
	set(value):
		walk = value
		if animation_tree != null:
			animation_tree.set("parameters/walk/blend_amount",value)

@export var walk_speed : float = 1.0 :
	set(value):
		walk_speed = value
		if animation_tree != null:
			animation_tree.set("parameters/walk_speed/scale",value)

@export_range(0.0,1.0) var drop_wepon_estate : float = 1.0:
	set(value):
		drop_wepon_estate = value
		if animation_tree != null:
			animation_tree.set("parameters/drop_wepon_estate/blend_amount",value)
