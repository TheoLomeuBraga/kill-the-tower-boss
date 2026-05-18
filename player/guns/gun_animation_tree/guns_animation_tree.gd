extends AnimationTree
class_name GunsAnimationTree

var ap_node : AnimationPlayer

func _ready() -> void:
	if anim_player == null:
		anim_player = "../AnimationPlayer"
		ap_node = get_node(anim_player)
		print(anim_player)
	
	tree_root = load("res://player/guns/gun_animation_tree/gun_blend_tree.tres").duplicate()

func shot() -> void:
	set("parameters/shot_1/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func shot_2() -> void:
	set("parameters/shot_2/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func stop_shot() -> void:
	set("parameters/shot_1/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT)
	set("parameters/shot_2/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT)

func reload() -> void:
	set("parameters/play_reload/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
