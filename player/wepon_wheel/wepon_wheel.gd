extends CenterContainer
class_name WeaponWheel

@onready var subviewport : SubViewport = $SubViewportContainer/SubViewport
@onready var cursor : Sprite2D = $SubViewportContainer/SubViewport/cursor
@onready var select_frame : Sprite2D = $SubViewportContainer/SubViewport/select_frame
@export var gun_control : GunControl
@export var player_movement : PlayerMovement

var node_placer : Node2D

var test_wepon_image : Texture2D = load("res://player/wepon_wheel/test_gun.png")

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
var wepons_ids : Dictionary[Sprite2D,int]
var last_weapon_id : int = 0

func place_node_rot(rot:float) -> void:
	var n : Sprite2D = Sprite2D.new()
	subviewport.add_child(n)
	n.texture = test_wepon_image
	
	node_placer.rotation = rot
	n.global_position = node_placer.to_global(Vector2(0,64+32))
	
	wepons_sprites[rot] = n
	
	wepons_ids[wepons_sprites[rot]] = last_weapon_id
	last_weapon_id+=1


var weapon_count : int = 8

var curent_selected_wepon : int = 0

func reset() -> void:
	
	weapon_count = gun_control.inventory.size()
	
	if not visible or weapon_count == 0:
		return
	
	for s : Sprite2D in wepons_ids:
		s.queue_free()
	
	wepons_sprites = {}
	wepons_ids = {}
	last_weapon_id = 0
	
	cursor.global_position = subviewport.size / 2
	node_placer = Node2D.new()
	subviewport.add_child(node_placer)
	node_placer.global_position = cursor.global_position
	
	for i : int in weapon_count:
		var rot : float = (((PI*2.0)/ float(weapon_count))*float(i)) + PI
		place_node_rot(rot)

func _ready() -> void:
	reset()
	visibility_changed.connect(reset)

func sort_coser_zero(a, b):	
	if abs(a) > abs(b):
		return true
	return false

func find_selected_wepon() -> void:
	
	var joy_vec : Vector2 = Input.get_vector("look_down","look_up","look_left","look_right")
	if joy_vec.length() > 0.25:
		cursor.look_at(cursor.global_position + (joy_vec*100))
	
	var angle_difs : Array[float]
	var angle_difs_sprites : Dictionary[float,Sprite2D]
	
	for f : float in wepons_sprites:
		
		var wepon_sprite : Sprite2D = wepons_sprites[f]
		var dif : float = angle_difference(cursor.rotation,f)
		angle_difs.push_back(dif)
		angle_difs_sprites[dif] = wepon_sprite
	
	angle_difs.sort_custom(sort_coser_zero)
	
	var selected_sprite : Sprite2D = angle_difs_sprites[angle_difs[0]]
	select_frame.global_transform = selected_sprite.global_transform
	
	curent_selected_wepon = wepons_ids[selected_sprite]

func _process(delta: float) -> void:
	
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
	
