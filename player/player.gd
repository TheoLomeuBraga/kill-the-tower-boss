extends CharacterBody3D
class_name Player

@onready var gun_control : GunControl = $Camera3D/GunControl
@onready var player_movement : PlayerMovement = $PlayerMovement
@onready var stats : Stats = $Stats
