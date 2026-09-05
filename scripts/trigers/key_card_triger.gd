extends Area3D
class_name KeyCardTriger

@export var key_type : GlobalEnums.KeyCards
@export var targets : Array[NodePath]


var sync_data : Dictionary

func on_body_entered(body:Node3D) -> void:
	if sync_data["used"]:
		return
	
	if not body is Player:
		return
	var player : Player = body
	if not player.keys.keys[key_type]:
		
		var _text : String = ""
		var _color : Color
		match key_type:
			GlobalEnums.KeyCards.RED:
				_text += "[color=red]red[/color] "
				_color = Color.RED
			GlobalEnums.KeyCards.BLUE:
				_text += "[color=deep_sky_blue]blue[/color] "
				_color = Color.DEEP_SKY_BLUE
			GlobalEnums.KeyCards.YELLOW:
				_text += "[color=yellow]yellow[/color] "
				_color = Color.YELLOW
		_text += "keycard needed"
		
		Player.player.hint.notfy(_text,3.0,_color)
		return
	
	for np : NodePath in targets:
		get_node(np).triger()
	
	sync_data["used"] = true
	
	

func _ready() -> void:
	sync_data["used"] = false
	if not PersistenceManager.has(self):
			PersistenceManager.register(self,sync_data)
	else:
		sync_data = PersistenceManager.get_ref(self)
	
	
	body_entered.connect(on_body_entered)
