extends Node3D
class_name ShaderCompiler

@onready var display : Node = $"display"

signal fineshed()

@export var to_compile : Array[PackedScene]

func disable_adudio_sources(n:Node) -> void:
	
	if n is AudioStreamPlayer:
		n.volume_linear = 0.0
	elif n is AudioStreamPlayer2D:
		n.volume_linear = 0.0
	elif n is AudioStreamPlayer3D:
		n.volume_linear = 0.0
	
	for c:Node in n.get_children():
		disable_adudio_sources(c)

func _ready() -> void:
	
	var count : int = 0
	
	for pc : PackedScene in to_compile:
		var n : Node = pc.instantiate()
		display.add_child(n)
		
		if n is GPUParticles3D:
			n.emitting = true
		
		disable_adudio_sources(n)
		
		count+=1
		if count >= 10:
			for i in range(0,3):
				await get_tree().process_frame
			
			for c:Node in display.get_children():
				c.queue_free()
			
			count = 0
	
	for i in range(0,3):
		await get_tree().process_frame
	
	
	fineshed.emit()
	print("resources compiled")
	queue_free()
