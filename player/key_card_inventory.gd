extends Node
class_name KeyCardInventory

@export var keys : Dictionary[GlobalEnums.KeyCards,bool] = {
	GlobalEnums.KeyCards.RED: false,
	GlobalEnums.KeyCards.YELLOW: false,
	GlobalEnums.KeyCards.BLUE: false,
}

func _ready() -> void:
	if not PersistenceManager.has(self):
			PersistenceManager.register(self,keys)
	else:
		keys = PersistenceManager.get_ref(self)
