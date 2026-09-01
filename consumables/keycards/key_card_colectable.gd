@tool
extends Node3D
class_name KeyCardColectable

@export var key_type : GlobalEnums.KeyCards
var sync_data : Dictionary

var block_on_body_enter : bool = false
func on_body_enter(node:Node3D) -> void:
	
	if block_on_body_enter:
		return
	
	if node is Player:
		
		var player : Player = node
		match key_type:
			GlobalEnums.KeyCards.RED:
				player.vignette.vignette_color = Color.RED
			GlobalEnums.KeyCards.YELLOW:
				player.vignette.vignette_color = Color.YELLOW
			GlobalEnums.KeyCards.BLUE:
				player.vignette.vignette_color = Color.BLUE
		
		
		for c:Node in node.get_children():
			if c is KeyCardInventory:
				c.keys[key_type] = true
		
		sync_data["existence"]=false
		
		block_on_body_enter = true
		
		visible = false
		
		$sfx.play()
		await $sfx.finished
		queue_free()

func _ready() -> void:
	
	$red.visible = false
	$yellow.visible = false
	$blue.visible = false
	
	if Engine.is_editor_hint():
		return
	
	sync_data["existence"] = true
	
	if not PersistenceManager.has(self):
		PersistenceManager.register(self,sync_data)
	else:
		sync_data = PersistenceManager.get_ref(self)
	
	if not sync_data["existence"]:
		queue_free()
	
	$Area3D.body_entered.connect(on_body_enter)
	
	
	

var time : float = 0.0
func _process(delta: float) -> void:
	time += delta
	$red.rotation.y = time*4.0
	$yellow.rotation.y = time*4.0
	$blue.rotation.y = time*4.0
	
	$red.position.y = sin(time*2.0)/4.0
	$yellow.position.y = sin(time*2.0)/4.0
	$blue.position.y = sin(time*2.0)/4.0
	
	match key_type:
		GlobalEnums.KeyCards.RED:
			$red.visible = true
		GlobalEnums.KeyCards.YELLOW:
			$yellow.visible = true
		GlobalEnums.KeyCards.BLUE:
			$blue.visible = true
