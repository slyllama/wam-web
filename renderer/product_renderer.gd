extends Node

@export var id := "" # pass ID so that you can save to HTML file

func save_to_html(html_text: String) -> void:
	if !id:
		Global.pconsole("Error saving to HTML: no ID assigned.")
		return
	var path := Global.PRODUCT_HTML_PATH + id + "/"
	if !DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)
	var _f = FileAccess.open(path + "index.html", FileAccess.WRITE)
	_f.store_string(html_text)
	_f.close()

func idt(num := 1) -> String:
	var output := ""
	for n in num:
		output += TextUtils.INDENT
	return(output)

func render(data: Dictionary) -> void:
	Global.load_product_html_template()
	
	var output := ""
	output += TextUtils.fmt("<div><code class='product-id-debug'>(" + id + ")</code></div>")
	if "title" in data:
		output += TextUtils.fmt(data.title, 0, "h1")
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
		if data.specifications != "":
			output += "<div class='table-wrapper'>\n"
			output += TextUtils.INDENT + "<table><tbody id='product-table'>\n"
			var _rows = data.specifications.split("\n")
			var _row_count := 0
			for _row in _rows:
				var _code: String = _row.split(",")[0]
				var _qty_number_id: String = "product-qty--" + _code
				var _qty_ele: String = "document.getElementById(`" + _qty_number_id + "`)"
				var _cart_function: String = ("\n" + idt(5) + "addToCart(\""
					+ _code + "\", \""
					+ id + "\", \""
					+ data.title + "\", "
					+ _qty_ele + ".value);")
				
				var _add_to_cart: String = (
					_qty_ele + ".value = Number(" + _qty_ele + ".value) + 1;"
					+ _cart_function + "\n" + idt(4))
				var _subtract_from_cart: String = (
					_qty_ele + ".value = Number(" + _qty_ele + ".value) - 1;"
					+ _cart_function + "\n" + idt(4))
				
				output += TextUtils.fmt("<tr id='row--" + _code + "'>", 2)
				var _columns = _row.split(",")
				for _column in _columns:
					for _s in TextUtils.SUBS:
						if _s in _column:
							_column = _column.replace(_s, TextUtils.SUBS[_s])
					output += TextUtils.fmt(_column, 3, "td")
				if _row_count != 0:
					output += TextUtils.fmt("<td>", 3)
					output += TextUtils.fmt("<input onchange='" + _cart_function + "\n" + idt(4) + "' type='number' style='width: 40px;' value=0 min=0 id='"
						+ _qty_number_id + "'/>", 4)
					output += TextUtils.fmt("<button style='width: 22px; margin-left: 0.15em;' onclick='" + _subtract_from_cart + "'>-</button>", 4)
					output += TextUtils.fmt("<button style='width: 22px;' onclick='" + _add_to_cart + "'>+</button>", 4)
					output += TextUtils.fmt("</td>", 3)
				else:
					output += TextUtils.fmt("<td>Qty</td>", 3)
				output += TextUtils.fmt("</tr>", 2)
				_row_count += 1
				
			output += TextUtils.INDENT + "</tbody></table>\n"
			output += "</div>\n"
			
			# Cart info
			output += "<div class='info'><p>Your can email your list of selected products to your local branch for processing and payment. <a href='../../page/cart'>View your list now.</a></p></div>"
			
			# Add compatibility chart
			var _cpath := Global.DATA_ROOT + "_template_chem.html"
			if FileAccess.file_exists(_cpath):
				var _cf = FileAccess.open(_cpath, FileAccess.READ)
				var _d = _cf.get_as_text()
				_cf.close()
				output += _d.replace("\n", "")
	
	var html_output = TextUtils.add_line_to_template(output, Global.product_html_template, "$CONTENT")
	if "title" in data:
		html_output = html_output.replace("$TITLE", data.title)
	html_output = html_output.replace("$IMG_PATH", "../../prodimg/" + id + ".jpg")
	save_to_html(html_output)
