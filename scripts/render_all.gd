extends Node

const ProductRenderer = preload("res://renderer/product_renderer.gd")
const CategoryRenderer = preload("res://renderer/category_renderer.gd")

func get_product_data(file: String) -> Dictionary:
	var _path = Global.PRODUCT_DATA_PATH + file
	var _f = FileAccess.open(_path, FileAccess.READ)
	var _json_parse = JSON.parse_string(_f.get_as_text())
	_f.close()
	
	if !_json_parse:
		print("JSON error.")
		return({})
	return(_json_parse)

func render_all() -> void:
	for file: String in DirAccess.get_files_at(Global.PRODUCT_DATA_PATH):
		var id: String = file.replace(".json", "")
		var _pr = ProductRenderer.new()
		_pr.id = id
		add_child(_pr)
		_pr.render(get_product_data(file))
		_pr.queue_free()
	
	Global.load_category_html_template()
	Global.category_titles = Global.get_category_titles()
	
	for file: String in DirAccess.get_files_at(Global.CATEGORY_DATA_PATH):
		var category_id: String = file.replace(".txt", "")
		var _cr = CategoryRenderer.new()
		_cr.id_list = Global.generate_list(Global.CATEGORY_DATA_PATH + category_id + ".txt", true)
		_cr.category_id = category_id
		if category_id in Global.category_titles:
			_cr.category_title = Global.category_titles[category_id]
		add_child(_cr)
		_cr.queue_free()
