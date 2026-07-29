extends SubViewportContainer

@export_flags_3d_render var traget_wepon_flag: int = 1 << 1

@export var player_model : PlayerModel

func update_res() -> void:
	$SubViewport.size = get_viewport().get_visible_rect().size
	

func _ready() -> void:
	return
	get_viewport().size_changed.connect(update_res)
	update_res()

func set_render_flag(target:Node) -> void:
	for n : Node in target.get_children():
		if n is GeometryInstance3D:
			var gi : GeometryInstance3D = n
			gi.layers = traget_wepon_flag
		set_render_flag(n)

func _process(delta: float) -> void:
	set_render_flag(player_model)
