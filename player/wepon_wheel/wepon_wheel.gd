extends CenterContainer
class_name WeaponWheel

@onready var subviewport : SubViewport = $SubViewportContainer/SubViewport
@onready var cursor : Sprite2D = $SubViewportContainer/SubViewport/cursor
@onready var select_frame : Sprite2D = $SubViewportContainer/SubViewport/select_frame
@export var gun_control : GunControl
@export var player_movement : PlayerMovement

@onready var stats : Stats = $"../Stats"

@export var weapon_name : String
@export var weapon_ammon_info_color : String = "[color=white]"
@export var weapon_ammon_info_icon : String = "res://icon.svg"
@export var weapon_ammon_info : String = "100/100" :
	set(value):
		weapon_ammon_info = value
		if $RichTextLabel:
			$RichTextLabel.text = "\n\n\n[center]"
			$RichTextLabel.text += "[color=black]"
			$RichTextLabel.text += weapon_name
			$RichTextLabel.text += "[/color]\n"
			$RichTextLabel.text += "[img height=1em]"
			$RichTextLabel.text += weapon_ammon_info_icon
			$RichTextLabel.text += "[/img]"
			$RichTextLabel.text += weapon_ammon_info_color
			$RichTextLabel.text += weapon_ammon_info
			$RichTextLabel.text += "[/color]"
			
			$RichTextLabel.text += "[/center]"
			

var node_placer : Node2D

static var test_wepon_image : Texture2D = load("res://player/wepon_wheel/test_gun.png")

var change_mouse : bool = false
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mm : InputEventMouseMotion = event
		
		var mouse_pos : Vector2 = mm.position
		
		var mouse_relative_pos : Vector2 = (Vector2(subviewport.size) * mouse_pos) / Vector2(get_viewport().get_visible_rect().size)
		cursor.look_at(mouse_relative_pos)
		cursor.rotation += PI/2
	
	
	if not change_mouse:
		return
	change_mouse = false
	
	if visible:
		Input.mouse_mode = Input.MouseMode.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MouseMode.MOUSE_MODE_CAPTURED

var wepons_sprites : Dictionary[float,Sprite2D]
var wepons_angles : Array[float]
var wepons : Dictionary[Sprite2D,GunInfo]
var last_weapon_id : int = 0

func place_node_rot(rot:float,gun:GunInfo) -> void:
	
	if not gun_control.inventory[gun]:
		last_weapon_id+=1
		return
	
	var n : Sprite2D = Sprite2D.new()
	subviewport.add_child(n)
	
	if gun:
		n.texture = gun.icon
	else:
		n.texture = test_wepon_image
	
	node_placer.rotation = rot
	n.global_position = node_placer.to_global(Vector2(0,64+32))
	
	wepons_sprites[rot] = n
	wepons_angles.push_back(rot)
	wepons[wepons_sprites[rot]] = gun_control.inventory_order[last_weapon_id]
	last_weapon_id+=1


var weapon_count : int = 8

var curent_selected_wepon : GunInfo

func reset() -> void:
	
	weapon_count = gun_control.inventory.size()
	
	if not visible or weapon_count == 0:
		return
	
	for s : Sprite2D in wepons:
		s.queue_free()
	
	wepons_sprites = {}
	wepons_angles = []
	wepons = {}
	last_weapon_id = 0
	
	cursor.global_position = subviewport.size / 2
	node_placer = Node2D.new()
	subviewport.add_child(node_placer)
	node_placer.global_position = cursor.global_position
	
	for i : int in weapon_count:
		var rot : float = (((PI*2.0)/ float(weapon_count))*float(i)) + PI
		place_node_rot(rot,gun_control.inventory_order[i])

func _ready() -> void:
	
	reset()
	visibility_changed.connect(reset)

func angle_sort(a, b):
	if abs(angle_difference(a,cursor.rotation)) > abs(angle_difference(b,cursor.rotation)):
		return true
	return false

func get_wepon_info(current_gun : GunInfo) -> String:
	var ret : String = ""
	
	var ammon_inventory:int = gun_control.ammon_inventory[current_gun.ammon_type]
	
	if current_gun.ammon_type != GlobalEnums.AmmonType.NONE:
		if current_gun.ammon_capacity > 0:
			var mag_ammon : int = max(0,gun_control.get_ammon_on_mag(current_gun))
			ret = str(gun_control.ammon_inventory[current_gun.ammon_type]) + "/" + str(mag_ammon)
		else:
			ret = str(gun_control.ammon_inventory[current_gun.ammon_type])
	elif current_gun.ammon_capacity > 0:
		ret = str(gun_control.get_ammon_on_mag(current_gun))
	
	return ret

func get_max_and_mag_ammons(current_gun:GunInfo) -> Vector2i:
	var ret : Vector2i
	var ammon_inventory:int = gun_control.ammon_inventory[current_gun.ammon_type]
	
	ret.x = current_gun.ammon_capacity
	
	
	if current_gun.ammon_type != GlobalEnums.AmmonType.NONE:
		if current_gun.ammon_capacity > 0:
			var mag_ammon : int = max(0,gun_control.get_ammon_on_mag(current_gun))
			
			ret.y = mag_ammon
		else:
			ret.y = gun_control.ammon_inventory[current_gun.ammon_type]
	elif current_gun.ammon_capacity > 0:
		ret.y = gun_control.get_ammon_on_mag(current_gun)
	
	return ret

func find_selected_wepon() -> void:
	
	var joy_vec : Vector2 = Input.get_vector("look_down","look_up","look_left","look_right")
	if joy_vec.length() > 0.25:
		cursor.look_at(cursor.global_position + (joy_vec*100))
	
	var local_wepons_angles = wepons_angles
	
	local_wepons_angles.sort_custom(angle_sort)
	
	var selected_sprite : Sprite2D = wepons_sprites[local_wepons_angles[0]]
	select_frame.global_transform = selected_sprite.global_transform
	
	curent_selected_wepon = wepons[selected_sprite]
	
	var max_mag : Vector2i = get_max_and_mag_ammons(curent_selected_wepon)
	
	
	if max_mag.y == 0:
		weapon_ammon_info_color = "[color=red]"
	elif max_mag.y < max_mag.x:
		weapon_ammon_info_color = "[color=dark_orange]"
	else:
		weapon_ammon_info_color = "[color=black]"
	
	
	weapon_ammon_info_icon = GlobalEnums.wepons_icons[curent_selected_wepon.ammon_type]
	
	weapon_name = curent_selected_wepon.name
	
	weapon_ammon_info = get_wepon_info(curent_selected_wepon)



func _process(delta: float) -> void:
	
	if not stats.is_alive():
		return
	
	player_movement.block_camera_rotetion = visible
	
	if Input.is_action_just_pressed("wepon_select"):
		visible = true
		change_mouse = true
	
	if not visible:
		return
	
	if Input.is_action_just_released("wepon_select"):
		
		gun_control.set_gun(curent_selected_wepon)
		visible = false
		change_mouse = true
	
	
	
	find_selected_wepon()
	
