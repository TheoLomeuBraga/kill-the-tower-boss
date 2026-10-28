extends Control

signal close()

func _ready() -> void:
	visible = false
	$ColorRect/close.grab_focus()
	$ColorRect/close.pressed.connect(close.emit)
	$ColorRect/close.pressed.connect(func():visible=not visible)
	$ColorRect/RichTextLabel.meta_clicked.connect(OS.shell_open)

func focus() -> void:
	visible = true
	$ColorRect/close.grab_focus()
