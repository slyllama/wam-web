extends Node

@export var category_id: String
@export var category_title := "(Category Title)"
@export_multiline var id_list: String

func save_to_html(html_text: String) -> void:
	if !category_id:
		print("Error saving to HTML: no ID assigned.")
		return
	if !DirAccess.make_dir_absolute(Global.CATEGORY_HTML_PATH):
		DirAccess.make_dir_absolute(Global.CATEGORY_HTML_PATH)
	var _f = FileAccess.open(Global.CATEGORY_HTML_PATH + category_id + ".html", FileAccess.WRITE)
	_f.store_string(html_text)
	_f.close()

var _c := 0 # product count

func _ready() -> void:
	if !id_list:
		print("Warning: no ID list for category renderer.")
		return
	
	var output := ""
	var _category = id_list.split(",")
	output += "<h1>" + category_title + "</h1>"
	
	for product in _category:
		if product[0] == "_": # Sub-category
			if _c > 0: output += "</div>\n"
			output += "<h2>" + product.replace("_", "") + "</h2>\n"
			output += "<div id='product-grid'>\n"
			continue
		
		var _path = Global.PRODUCT_DATA_PATH + product + ".json"
		var _f = FileAccess.open(_path, FileAccess.READ)
		if !_f:
			#output += TextUtils.INDENT + "<div style='color: #bbb; text-decoration: line-through;'>" + product + "</div>\n"
			continue
		
		var _json_parse = JSON.parse_string(_f.get_as_text())
		_f.close()
		var data = _json_parse
		
		# Get image
		var _img_src := "#"
		if "temp_img_path" in data:
			_img_src = data.temp_img_path
		
		output += TextUtils.fmt("<div>", 1)
		output += TextUtils.fmt("<a href='../products/" + product + ".html'>", 2)
		output += TextUtils.fmt("<img class='product-image' loading='lazy' src='" + _img_src + "' />", 3)
		output += TextUtils.fmt("</a>", 2)
		output += TextUtils.fmt("<div class='product-details-btn'><div>Details</div></div>", 2)
		output += TextUtils.fmt("<p class='product-title'>", 2)
		output += TextUtils.INDENT + TextUtils.INDENT + TextUtils.INDENT +"<a href='../products/" + product + ".html'>"
		if "title" in data:
			output += data.title
		else:
			output += product + " (?)"
		output += "</a>\n"
		output += TextUtils.fmt("</p>", 2)
		if "subtitle" in data:
			output += TextUtils.fmt("<p class='product-subtitle'>" + data.subtitle + "</p>", 2)
		output += TextUtils.fmt("</div>", 1)
		
		_c += 1
	output += "</div>\n"
	
	output = output.strip_edges(false, true)
	var html_output = TextUtils.add_line_to_template(output, Global.category_html_template, "$CONTENT")
	html_output = html_output.replace("$TITLE", category_title)
	save_to_html(html_output)
