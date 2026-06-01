extends CharacterBody3D
class_name Player

static var player : Player = null

@onready var gun_control : GunControl = $Camera3D/GunControl
@onready var player_movement : PlayerMovement = $PlayerMovement
@onready var stats : Stats = $Stats

signal damage_enemy
signal kill_enemy

func _ready() -> void:
	player = self

func _exit_tree() -> void:
	player = null
