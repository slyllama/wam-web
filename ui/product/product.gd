extends ScrollContainer

const Property = preload("res://ui/product/property/property.tscn")
const ProductRenderer = preload("res://renderer/product_renderer.gd")

@export var id: String:
	set(_id):
		id = _id
		load_file()

var data: Dictionary

var file_loaded := false

signal saved

func validate_file() -> bool:
	if !id:
		visible = false
		return(false) # no ID set
	var _path = Global.PRODUCT_DATA_PATH + id + ".json"
	if !FileAccess.file_exists(_path):
		var _f = FileAccess.open(_path, FileAccess.WRITE)
		_f.store_string("{}")
		_f.close()
	
	visible = true
	return(true)

func load_file() -> void:
	data = {}
	if validate_file():
		var _path = Global.PRODUCT_DATA_PATH + id + ".json"
		var _f = FileAccess.open(_path, FileAccess.READ)
		var _json_parse = JSON.parse_string(_f.get_as_text())
		_f.close()
		
		if !_json_parse: return
		data = _json_parse
	file_loaded = true

func save_file() -> void:
	if !validate_file(): return
	var _path = Global.PRODUCT_DATA_PATH + id + ".json"
	var _f = FileAccess.open(_path, FileAccess.WRITE)
	
	var _json_string = JSON.stringify(data, "    ")
	_f.store_string(_json_string)
	_f.close()
	
	Global.status_updated.emit("Saved file '" + id + ".json'.")
	saved.emit()

func apply_changes() -> void: # TODO: try and keep the same order as populate()
	data.title = %Title.text
	data.subtitle = %Subtitle.text
	data.description = %Description.text
	data.specifications = %SpecTable.text
	data.temp_img_path = %ImagePath.text
	
	var _properties = []
	for _p in %Properties.get_children():
		if "property" in _p:
			_properties.append(_p.property)
	data.properties = _properties

func populate(clear := true) -> void:
	%ID.text = id
	if clear and !Input.is_action_pressed("shift"):
		%Title.text = ""
		%Subtitle.text = ""
		%ImagePath.text = ""
		%Description.text = ""
		%SpecTable.text = ""
		for _p in %Properties.get_children():
			_p.queue_free()
	
	if "title" in data: %Title.text = data.title
	if "description" in data: %Description.text = data.description
	if "subtitle" in data: %Subtitle.text = data.subtitle
	if "temp_img_path" in data: %ImagePath.text = data.temp_img_path
	if "properties" in data:
		var _properties = data.properties
		for _p in _properties:
			var _n = Property.instantiate()
			_n.property = _p
			# Add new property line on tab out
			_n.new_line_requested.connect(func():
				_on_add_property_pressed())
			_n.deletion_requested.connect(func():
				await get_tree().process_frame
				# Focus on the last line now existing
				%Properties.get_children()[%Properties.get_child_count() - 1].get_node("Name").grab_focus())
			%Properties.add_child(_n)
	
	if "specifications" in data:
		%SpecTable.text = data.specifications

func _ready() -> void:
	if !file_loaded:
		visible = false
		return
	populate()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("render"): # Ctrl-S shortcut
		_on_render_pressed()

func _on_add_property_pressed() -> void:
	var _n = Property.instantiate()
	_n.property = {}
	# Add new property line on tab out
	# TODO: doing this twice sucks
	_n.new_line_requested.connect(func():
		_on_add_property_pressed())
	_n.deletion_requested.connect(func():
		await get_tree().process_frame
		# Focus on the last line now existing
		%Properties.get_children()[%Properties.get_child_count() - 1].get_node("Value").grab_focus())
	%Properties.add_child(_n)
	await get_tree().process_frame
	_n.get_node("Name").grab_focus()

func _on_save_pressed() -> void:
	apply_changes()
	save_file()

func _on_reload_pressed() -> void:
	populate()

# TODO: for testing
func _on_render_pressed() -> void:
	apply_changes()
	save_file()
	
	var _pr = ProductRenderer.new()
	_pr.id = id
	add_child(_pr)
	_pr.render(data)
	_pr.queue_free()
	
	await get_tree().process_frame
	Global.status_updated.emit("Rendered.")

func _on_format_spec_table_pressed() -> void:
	%SpecTable.text = %SpecTable.text.replace(" \t", ",")
	%SpecTable.text = %SpecTable.text.replace("\t", ",")
	
	%SpecTable.text = %SpecTable.text.replace("ID Size (mm)", "ID (mm)")
	%SpecTable.text = %SpecTable.text.replace("OD Size (mm)", "OD (mm)")
	%SpecTable.text = %SpecTable.text.replace("Thread Type", "Thread")
	%SpecTable.text = %SpecTable.text.replace("Slip On", "Slip-on")
	%SpecTable.text = %SpecTable.text.replace("Working Pressure (psi)", "WP (psi)")
	%SpecTable.text = %SpecTable.text.replace("Burst Pressure (psi)", "BP (psi)")
	%SpecTable.text = %SpecTable.text.replace("Coil Length(s) (m)", "Length (m)")
	%SpecTable.text = %SpecTable.text.replace("Min Bend Radius (mm)", "MBR (mm)")
	%SpecTable.text = %SpecTable.text.replace(" inch", "inch")

func _on_remove_end_column_pressed() -> void:
	var csv: Array = %SpecTable.text.split("\n")
	var output := ""
	for line in csv:
		var line_array: Array = line.split(",")
		for i in range(0, line_array.size() - 1):
			output += line_array[i] + ","
		output = output.rstrip(",")
		output += "\n"
	output = output.rstrip("\n")
	%SpecTable.text = output
