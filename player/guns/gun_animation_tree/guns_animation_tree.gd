@tool
extends AnimationTree
class_name GunsAnimationTree

var ap_node : AnimationPlayer

func _ready() -> void:
	if anim_player == null:
		ap_node = get_node(anim_player)
	
	tree_root = load("res://player/guns/gun_animation_tree/gun_blend_tree.tres").duplicate()
	tree_root.set("parameters/Add2/add_amount",1.0)
	

func shot() -> void:
	set("parameters/shot_1/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func shot_2() -> void:
	set("parameters/shot_2/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func abort_shot() -> void:
	set("parameters/shot_1/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	set("parameters/shot_2/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)

func stop_shot() -> void:
	set("parameters/shot_1/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT)
	set("parameters/shot_2/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT)

func reload() -> void:
	set("parameters/shot_1/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	set("parameters/shot_2/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	set("parameters/play_reload/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
