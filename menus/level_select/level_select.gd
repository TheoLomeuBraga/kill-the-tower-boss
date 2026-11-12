extends Control

signal close()

func focus() -> void:
	$Panel/ColorRect2/ScrollContainer/VBoxContainer.get_child(0).grab_focus()

var current_chapter : int = 0
func select_chapter(no:int) -> void:
	for c : ScrollContainer in $Panel/ColorRect3.get_children():
		c.visible=false
	$Panel/ColorRect3.get_child(no).visible=true
	current_chapter = no
	await get_tree().process_frame
	$Panel/ColorRect3.get_child(no).get_child(0).get_child(0).focus()

func _ready() -> void:
	
	for c : ScrollContainer in $Panel/ColorRect3.get_children():
		c.visible=false
	$Panel/ColorRect3.get_child(0).visible = true
	
	$back.pressed.connect(func():visible=false)
	$back.pressed.connect(close.emit)
	
	
	for i:int in $Panel/ColorRect2/ScrollContainer/VBoxContainer.get_child_count():
		var c:Button = $Panel/ColorRect2/ScrollContainer/VBoxContainer.get_child(i)
		c.pressed.connect(select_chapter.bind(i))
	

func _process(delta: float) -> void:
	
	if not visible:
		return
	
	if Input.is_action_just_pressed("ui_cancel"):
		for n:Control in $Panel/ColorRect3.get_child(current_chapter).get_child(0).get_children():
			if n.this_has_focus():
				focus()
				return
		visible=false
		close.emit()
