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
	
	
	for c : Node in $Panel/ColorRect2/ScrollContainer/VBoxContainer.get_children():
		if not c is Button:
			continue
		
		var b : Button = c
		b.focus_neighbor_right = $Panel/ColorRect3/ScrollContainer/HBoxContainer.get_child(0).get_button().get_path()
	
	var last_button:Button = $Panel/ColorRect3/ScrollContainer/HBoxContainer.get_child($Panel/ColorRect3/ScrollContainer/HBoxContainer/LevelTumbnail3.get_child_count()).get_button()
	last_button.focus_neighbor_bottom = $back.get_path()
	
	$back.focus_neighbor_top = $Panel/ColorRect2/ScrollContainer/VBoxContainer/Button.get_path()
	
	for c : Control in $Panel/ColorRect3/ScrollContainer/HBoxContainer.get_children():
		c.get_button().focus_neighbor_left = $Panel/ColorRect2/ScrollContainer/VBoxContainer.get_child(0).get_path()
	

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
