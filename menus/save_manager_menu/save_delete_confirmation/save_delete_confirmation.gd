extends Control
class_name SaveDeleteConfirmationScreen

@export var save_name : String:
	set(value):
		save_name = value
		if $VBoxContainer/RichTextLabel:
			$VBoxContainer/RichTextLabel.text = ""
			$VBoxContainer/RichTextLabel.text += tr("delete: %s ?")  % [save_name]
			$VBoxContainer/RichTextLabel.text += "\n"
			$VBoxContainer/RichTextLabel.text += tr("[color=red]this will be permanent[/color]")

signal confirmation(bool)

func _ready() -> void:
	$VBoxContainer/HBoxContainer/no.pressed.connect(confirmation.emit.bind(false))
	$VBoxContainer/HBoxContainer/yes.pressed.connect(confirmation.emit.bind(true))
	$VBoxContainer/HBoxContainer/no.grab_focus()
