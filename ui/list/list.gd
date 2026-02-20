extends ScrollContainer

const ProductRenderer = preload("res://renderer/product_renderer.gd")

signal id_clicked(id: String)
@export_multiline var id_list: String

# Return a list of all products in the product data folder
func get_all_products() -> Array[String]:
	var _product_list: Array[String] = []
	var _product_dir := DirAccess.open(Global.PRODUCT_DATA_PATH)
	if _product_dir:
		_product_dir.list_dir_begin()
		for _f: String in _product_dir.get_files():
			if ".json" in _f:
				_product_list.append(_f.replace(".json", ""))
	return(_product_list)

# Render all to HTML
func render_all() -> void:
	for product in get_all_products():
		var _path = Global.PRODUCT_DATA_PATH + product + ".json"
		var _f = FileAccess.open(_path, FileAccess.READ)
		var _json_parse = JSON.parse_string(_f.get_as_text())
		_f.close()
		var data = _json_parse
		
		var _pr = ProductRenderer.new()
		_pr.id = product
		add_child(_pr)
		_pr.render(data)
		_pr.queue_free()
	Global.status_updated.emit("All product HTML rendered.")

var selected: Button

func populate() -> void:
	var last_id := ""
	if selected:
		last_id = selected.text
	
	for _n in $Box.get_children():
		_n.queue_free()
	
	var _p
	if id_list:
		_p = id_list.split(",")
	else: return
	
	for _id in _p:
		var _b = Button.new()
		
		if _id == last_id:
			selected = _b
		
		_b.text = _id
		_b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		_b.theme_type_variation = "ListButton"
		_b.add_theme_color_override("font_color", Color("333333"))
		_b.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		_b.set_meta("this_is_a_list_woohoo", true)
		_b.pressed.connect(func():
			_b.add_theme_stylebox_override("normal", load("res://generic/button_selected.tres"))
			_b.add_theme_color_override("font_color", Color("#FFFFFF"))
			id_clicked.emit(_id)
			await get_tree().process_frame
			selected = _b)
		$Box.add_child(_b)
		
		if !FileAccess.file_exists(Global.PRODUCT_DATA_PATH + _id + ".json"):
			_b.add_theme_color_override("font_color", Color("ccccccff"))
	# Reselect on reload
	if selected:
		selected.add_theme_stylebox_override("normal", load("res://generic/button_selected.tres"))
		selected.add_theme_color_override("font_color", Color("#FFFFFF"))

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click") and get_window().gui_get_hovered_control():
		if selected and get_window().gui_get_hovered_control().has_meta("this_is_a_list_woohoo"):
			selected.add_theme_color_override("font_color", Color("333333"))
			selected.add_theme_stylebox_override("normal", StyleBoxEmpty.new())

func _ready() -> void:
	populate()

func _on_render_all_pressed() -> void:
	render_all()
