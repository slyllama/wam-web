extends VBoxContainer

signal new_product_created(id: String)
signal new_product_duplicate(id: String)

func _on_create_pressed() -> void:
	var _id = $NewProduct.text
	if !_id or _id == "": return # invalid
	new_product_created.emit(_id)
	
	Global.status_updated.emit("Created '" + _id + "'.")

func _on_duplicate_pressed() -> void:
	var _id = $NewProduct.text
	if !_id or _id == "": return # invalid
	new_product_duplicate.emit(_id)

func _on_new_product_text_submitted(_new_text: String) -> void:
	_on_create_pressed()
