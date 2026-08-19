extends Node

var state_backup : Dictionary[NodePath,Dictionary] = {}
var state : Dictionary[NodePath,Dictionary] = {}

signal on_save()
signal on_load()
signal on_clean()

func save_state() -> void:
	on_save.emit()
	state_backup = state.duplicate()

func load_state() -> void:
	state = state_backup.duplicate()
	on_load.emit()

func clean():
	on_clean.emit()
	state_backup = {}
	state = {}

func write(node:Node,dictionary:Dictionary) -> void:
	var p : NodePath = node.get_path()
	state[p] = dictionary.duplicate()

func register(node:Node,dictionary:Dictionary) -> void:
	var p : NodePath = node.get_path()
	state[p] = dictionary.duplicate()
	state_backup[p] = dictionary.duplicate()

func has(node:Node) -> bool:
	return state.has(node.get_path())

func read(node:Node) -> Dictionary:
	var p : NodePath = node.get_path()
	if state.has(p):
		return state[p].duplicate()
	return {}
