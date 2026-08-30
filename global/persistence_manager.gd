extends Node

var state_backup : Dictionary[NodePath,Dictionary] = {}
var state : Dictionary[NodePath,Dictionary] = {}

signal on_save()
signal on_load()
signal on_clean()

func save_state() -> void:
	on_save.emit()
	state_backup.clear()
	for n:NodePath in state:
		state_backup[n] = state[n].duplicate()

func load_state() -> void:
	state.clear()
	for n:NodePath in state_backup:
		state[n] = state_backup[n].duplicate()
	on_load.emit()

func clean():
	on_clean.emit()
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
