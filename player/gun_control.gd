extends Node
class_name GunControl

@export var body : CharacterBody3D
@export var model : PlayerModel

@export var inventory : Array[GunInfo]
@export var current_wepon : int = 0
