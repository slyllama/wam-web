extends Node

const HTML_ROOT := "res://web/"

const PRODUCT_DATA_PATH := HTML_ROOT + "product_data/"
const PRODUCT_HTML_PATH := HTML_ROOT + "products/"
const PRODUCT_HTML_TEMPLATE_PATH := HTML_ROOT + "_template_product.html"

const CATEGORY_DATA_PATH := HTML_ROOT + "category_data/"
const CATEGORY_HTML_PATH := HTML_ROOT + "categories/"
const CATEGORY_HTML_TEMPLATE_PATH := HTML_ROOT + "_template_category.html"

const RETINA_SCALE_FACTOR = 1.6

signal status_updated(status: String)

var product_html_template := ""
var category_html_template := ""

func generate_list(list_file: String, include_subcats := false) -> String:
	var _output = ""
	if !FileAccess.file_exists(list_file):
		return(_output) # return a blank list if the file doesn't exist
	var _f = FileAccess.open(list_file, FileAccess.READ)
	var _f_string: String = _f.get_as_text()
	_f.close()
	
	for _line in _f_string.split("\n"):
		if _line != "":
			if !include_subcats and _line[0] == "_": continue
			_output += _line.strip_edges() + ","
	
	return(_output.replace(",,", ""))

func load_product_html_template() -> void: # use for reloading
	if FileAccess.file_exists(PRODUCT_HTML_TEMPLATE_PATH):
		var _f = FileAccess.open(PRODUCT_HTML_TEMPLATE_PATH, FileAccess.READ)
		product_html_template = _f.get_as_text()
		_f.close()

func load_category_html_template() -> void: # use for reloading
	if FileAccess.file_exists(CATEGORY_HTML_TEMPLATE_PATH):
		var _f = FileAccess.open(CATEGORY_HTML_TEMPLATE_PATH, FileAccess.READ)
		category_html_template = _f.get_as_text()
		_f.close()

func _fill_dir(dir: String) -> void: # creates a directory, but only if it doesn't already exist
	if !DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_absolute(dir)

func _init() -> void:
	# Set up directories
	_fill_dir(PRODUCT_DATA_PATH)
	_fill_dir(PRODUCT_HTML_PATH)
	
	load_product_html_template()

func _ready() -> void:
	# Render scale on retina displays
	if DisplayServer.screen_get_size().x > 2000:
		get_window().content_scale_factor = RETINA_SCALE_FACTOR
		get_window().size *= RETINA_SCALE_FACTOR
