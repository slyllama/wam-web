extends Node

@export var category_id: String
@export var category_title := "(Category Title)"
@export_multiline var id_list: String

signal total_reported(count: int)
signal missing_reported(count: int)
var total := 0
var missing := 0

func save_to_html(html_text: String) -> void:
	if !category_id:
		Global.pconsole("Error saving to HTML: no ID assigned.")
		return
	var path := Global.CATEGORY_HTML_PATH + category_id + "/"
	if !DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)
	
	var _f = FileAccess.open(path + "index.html", FileAccess.WRITE)
	_f.store_string(html_text)
	_f.close()

var _c := 0 # product count

func _ready() -> void:
	if !id_list:
		Global.pconsole("Warning: no ID list for category renderer.")
		return
	
	var has_subcats := false
	var master_output := ""
	var output := ""
	var _category = id_list.split(",")
	master_output += "<h1>" + category_title.strip_edges(false, true) + "</h1>\n"
	master_output += "<p style='text-align: center; margin: 0 10%;'><b>Jump to:</b>&nbsp;&nbsp;&nbsp;&nbsp;"
	
	for product in _category:
		if !product: continue
		if product[0] == "_": # Sub-category
			if product != "_": has_subcats = true
			if _c > 0: output += "</div>\n"
			var _subhead_id = "subhead--" + product.replace("_", "").replace(" ", "")
			output += TextUtils.fmt("<h2 id='" + _subhead_id + "'>" + product.replace("_", "") + "</h2>", 0)
			output += "<div id='product-grid'>\n"
			master_output += TextUtils.fmt("<a class='subhead-links' href='#" + _subhead_id + "'>"
				+ product.replace("_", "")
				+ "</a>&nbsp;&nbsp;&nbsp;&nbsp;", 1)
			continue
		
		_c += 1
		
		var _path = Global.PRODUCT_DATA_PATH + product + ".json"
		var _f = FileAccess.open(_path, FileAccess.READ)
		total += 1
		if !_f:
			#output += TextUtils.INDENT + "<div style='color: #bbb; text-decoration: line-through;'>" + product + "</div>\n"
			output += TextUtils.fmt("<div>", 1)
			output += TextUtils.fmt("<img alt='' class='product-image' style='margin-bottom: 0;' loading='lazy' src='../../img/unknown.png' />", 2)
			output += (TextUtils.INDENT + TextUtils.INDENT
				+ "<p class='product-title' style='hyphens: auto; word-wrap: anywhere; margin-top: 0.25em; margin-bottom: 1em; color: #aaa; font-weight: normal;'>"
				+ product + "</p>\n")
			output += TextUtils.fmt("</div>", 1)
			missing += 1
			continue
		
		var _json_parse = JSON.parse_string(_f.get_as_text())
		_f.close()
		var data = _json_parse
		
		# Get image
		var _img_src: String = "../../prodimg/" + product + ".jpg"
		#if "temp_img_path" in data:
			#_img_src = data.temp_img_path
		
		output += TextUtils.fmt("<div>", 1)
		output += TextUtils.fmt("<a href='../../product/" + product + "'>", 2)
		output += TextUtils.fmt("<img alt='' class='product-image' loading='lazy' src='" + _img_src + "' />", 3)
		output += TextUtils.fmt("<div class='product-details-btn'><div>Details</div></div>", 3)
		output += TextUtils.fmt("</a>", 2)
		output += TextUtils.fmt("<p class='product-title'>", 2)
		output += TextUtils.INDENT + TextUtils.INDENT + TextUtils.INDENT +"<a href='../../product/" + product + "'>"
		if "title" in data:
			output += data.title
		else:
			output += product + " (?)"
		output += "</a>\n"
		output += TextUtils.fmt("</p>", 2)
		if "subtitle" in data:
			var subtitle: String = data.subtitle
			if "(check)" in subtitle:
				subtitle = "<span style='background: #FFFF00'>&thinsp;(Check product)&thinsp;</span>"
			output += TextUtils.fmt("<p class='product-subtitle'>" + subtitle + "</p>", 2)
		output += TextUtils.fmt("</div>", 1)
	output += "</div>\n"
	
	output = output.strip_edges(false, true)
	
	# We only add subcategories via master_output if any exist
	var html_output
	var qty_text := "entries"
	if _c == 1: qty_text = "entry"
	# Debugging text
	var qty_html := ("<div><code class='product-id-debug'>("
		+ category_id + ": " + str(_c) + " "
		+ qty_text + ", " + str(missing)
		+ " unresolved)</code></div>\n")
	if has_subcats:
		html_output = TextUtils.add_line_to_template(qty_html + master_output + "</p>\n" + output, Global.category_html_template, "$CONTENT")
	else:
		html_output = TextUtils.add_line_to_template(qty_html + "<h1>" + category_title.strip_edges(false, true) + "</h1>\n" + output, Global.category_html_template, "$CONTENT")
	
	html_output = html_output.replace("$TITLE", category_title)
	save_to_html(html_output)
	
	total_reported.emit(total)
	missing_reported.emit(missing)
