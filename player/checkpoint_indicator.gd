extends Node

func _ready() -> void:
	if not get_tree():
		return
	while not Player.player:
		await get_tree().process_frame
	PersistenceManager.on_save.connect(Player.player.hint.notfy.bind("[color=yellow]chekpoint[/color]",1.0,Color.YELLOW))
	
