extends CharacterBody3D
class_name Player

static var player : Player = null

@onready var gun_control : GunControl = $Camera3D/GunControl
@onready var movement : PlayerMovement = $PlayerMovement
@onready var model : PlayerModel = $Camera3D/PlayerModel
@onready var hud : PlayerHud = $HUD
@onready var stats : Stats = $Stats
@onready var vignette : VignetteEffect = $Vignette
@onready var keys : KeyCardInventory = $KeyCardInventory
@onready var hint : Hint = $Hint

signal damage_enemy
signal kill_enemy

func damage_vignette(damage:int) -> void:
	vignette.vignette_color = Color.RED
	vignette.outer_radius = 1.2

func _ready() -> void:
	player = self
	stats.damaged.connect(damage_vignette)
	PersistenceManager.save_state()

func _exit_tree() -> void:
	player = null
