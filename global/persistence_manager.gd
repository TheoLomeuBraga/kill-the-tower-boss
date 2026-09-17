extends Node

var save_name : String = "slot_1"
var save_data : Dictionary
var state_backup : Dictionary[NodePath,Dictionary] = {}
var state : Dictionary[NodePath,Dictionary] = {}

signal on_save_game()
signal on_load_game()

signal on_save_state()
signal on_load_state()
signal on_clean_state()

func save_state() -> void:
	on_save_state.emit()
	state_backup.clear()
	for n:NodePath in state:
		state_backup[n] = state[n].duplicate()

func load_state() -> void:
	state.clear()
	for n:NodePath in state_backup:
		state[n] = state_backup[n].duplicate()
	on_load_state.emit()

func clean():
	on_clean_state.emit()
	state_backup = {}
	state = {}

func register(node:Node,dictionary:Dictionary) -> void:
	var p : NodePath = node.get_path()
	state[p] = dictionary
	state_backup[p] = dictionary.duplicate()

func has(node:Node) -> bool:
	return state.has(node.get_path())

func get_ref(node:Node) -> Dictionary:
	var p : NodePath = node.get_path()
	if state.has(p):
		return state[p]
	return {}

func name_to_save_path(id:int) -> String: 
	return "user://save/" + save_name + ".save" + str(id)

func save_game() -> void:
	
	on_save_game.emit()
	
	#TODO

func try_load_game() -> Variant:
	var ret : Variant
	#TODO
	return ret

func load_game() -> void:
	
	#TODO
	
	on_load_game.emit()
