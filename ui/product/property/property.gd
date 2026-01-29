extends HBoxContainer

signal deletion_requested
signal new_line_requested

@export var property: Dictionary:
	set(_property):
		property = _property

func _ready() -> void:
	if !property:
		property = { "name": "", "value": "" }
		return
	if "name" in property: $Name.text = property.name
	if "value" in property: $Value.text = property.value

func _input(_event) -> void:
	if $Value.has_focus():
		if Input.is_action_just_pressed("ui_focus_next"):
			new_line_requested.emit()
	# Delete whole line on backspace
	if $Name.has_focus() and $Name.text == "":
		if Input.is_action_just_pressed("ui_text_backspace"):
			deletion_requested.emit()
			queue_free()

func _on_delete_pressed() -> void:
	queue_free()

func _on_name_text_changed(new_text: String) -> void:
	property.name = new_text

func _on_value_text_changed(new_text: String) -> void:
	property.value = new_text
