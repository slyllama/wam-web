extends Node

@export var id := "" # pass ID so that you can save to HTML file

func save_to_html(html_text: String) -> void:
	if !id:
		print("Error saving to HTML: no ID assigned.")
		return
	var path := Global.PRODUCT_HTML_PATH + id + "/"
	if !DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_absolute(path)
	var _f = FileAccess.open(path + "index.html", FileAccess.WRITE)
	_f.store_string(html_text)
	_f.close()

func render(data: Dictionary) -> void:
	Global.load_product_html_template()
	
	var output := ""
	output += TextUtils.fmt("<div><code class='product-id-debug'>" + id + "</code></div>")
	if "title" in data:
		output += TextUtils.fmt(data.title + "<span style='font-weight: normal;'> &mdash; " + data.subtitle + "</span>", 0, "h1")
	if "description" in data:
		output += TextUtils.fmt(data.description, 0, "p")
	if "properties" in data:
		output += "<ul>\n"
		for _p in data.properties:
			if "temp_range" in _p.name.to_lower():
				output += TextUtils.fmt("<b>Temperature range:</b> "
					+ TextUtils.format_temp_range(_p.value), 1, "li")
			else:
				output += TextUtils.fmt("<b>" + _p.name + ":</b> "
					+ _p.value, 1, "li")
		output += "</ul>\n"
	
	if "specifications" in data:
		output += "<div class='table-wrapper'>\n"
		output += TextUtils.INDENT + "<table><tbody id='product-table'>\n"
		var _rows = data.specifications.split("\n")
		var _row_count := 0
		for _row in _rows:
			var _code: String = _row.split(",")[0]
			var _qty_number_id: String = "product-qty--" + _code
			var _cart_function: String = ("addToCart(\""
				+ _code + "\", \""
				+ id + "\", \""
				+ data.title + "\", "
				+ "document.getElementById(`" + _qty_number_id + "`).value);")
			
			output += TextUtils.fmt("<tr id='row--" + _code + "'>", 2)
			var _columns = _row.split(",")
			for _column in _columns:
				for _s in TextUtils.SUBS:
					if _s in _column:
						_column = _column.replace(_s, TextUtils.SUBS[_s])
				output += TextUtils.fmt(_column, 3, "td")
			if _row_count != 0:
				output += TextUtils.fmt("<td>", 3)
				output += TextUtils.fmt("<input onchange='" + _cart_function + "' type='number' style='width: 40px;' value=0 min=0 id='"
					+ _qty_number_id + "'/><button style='margin-left: 0.15em;' onclick='" + _cart_function + "'>+</button>", 4)
				output += TextUtils.fmt("</td>", 3)
			else:
				output += TextUtils.fmt("<td>Qty</td>", 3)
			output += TextUtils.fmt("</tr>", 2)
			_row_count += 1
			
		output += TextUtils.INDENT + "</tbody></table>\n"
		output += "</div>\n"
	
	var html_output = TextUtils.add_line_to_template(output, Global.product_html_template, "$CONTENT")
	if "title" in data:
		html_output = html_output.replace("$TITLE", data.title)
	if "temp_img_path" in data:
		html_output = html_output.replace("$IMG_PATH", data.temp_img_path)
	save_to_html(html_output)
