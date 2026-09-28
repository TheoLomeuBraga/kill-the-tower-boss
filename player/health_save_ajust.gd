extends Node

@onready var stats : Stats = $".."

@export var minimun_health:int=25

func on_save() -> void:
	SaveManager.game_data["player_health"] = stats.health

func on_load() -> void:
	if SaveManager.game_data.has("player_health"):
		stats.health = max(SaveManager.game_data["player_health"],minimun_health)

func _ready() -> void:
	stats.sync_stats=false
	SaveManager.on_save_game.connect(on_save)
	on_load()
	
