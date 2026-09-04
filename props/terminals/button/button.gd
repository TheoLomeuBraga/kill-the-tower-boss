extends Node3D

enum ButtonMode {ONE_USE,ON_OFF,MULT_USE}
@export var mode : ButtonMode = ButtonMode.ONE_USE

var sync_data : Dictionary


var can_paly_sound:bool=false
var active : bool:
	set(value):
		active = value
		
		if can_paly_sound:
			if active and $pressed_audio:
				$pressed_audio.play()
			if not active and $unpressed_audio and mode != ButtonMode.MULT_USE:
				$unpressed_audio.play()
		
		if $Cube_001:
			$Cube_001.visible = not value
		
		if $Cube_002:
			$Cube_002.visible = value

var timer : Timer
func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	
	sync_data["active"] = false
	if not PersistenceManager.has(self):
		PersistenceManager.register(self,sync_data)
	else:
		sync_data = PersistenceManager.get_ref(self)
	active = sync_data["active"]
	
	await get_tree().process_frame
	can_paly_sound = true

var block : bool = false
func triger() -> void:
	
	
	
	match mode:
		ButtonMode.ONE_USE:
			if not active:
				active = true
				sync_data["active"] = active
		ButtonMode.ON_OFF:
			active = not active
			sync_data["active"] = active
		ButtonMode.MULT_USE:
			if block:
				return
			block = true
			active = true
			timer.start(0.5)
			await timer.timeout
			active = false
			block = false
