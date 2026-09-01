extends HBoxContainer

@onready var kci : KeyCardInventory = $"../../KeyCardInventory"

func _process(delta: float) -> void:
	$red.visible = kci.keys[GlobalEnums.KeyCards.RED]
	$yellow.visible = kci.keys[GlobalEnums.KeyCards.YELLOW]
	$blue.visible = kci.keys[GlobalEnums.KeyCards.BLUE]
