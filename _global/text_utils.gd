extends Node

const INDENT = "\t"

const SUBS = {
	"code": "Code",
	"id_imp": "ID (Imp)",
	"id_mm": "ID (mm)",
	"od_mm": "OD (mm)",
	"wp_bar": "WP (bar)",
	"mbr_mm": "MBR (mm)",
	"weight_kg": "(kg/m)",
	"Thread": "Thread Type",
	"Slip-on": "Slip On",
	"inch": "&Prime;"
}

func format_temp_range(temp_range: String) -> String:
	var _t = temp_range.replace("-", "&minus;").split(",")
	var _str = _t[0] + "&deg;c &ndash; " + _t[1] + "&deg;c"
	return(_str)

func add_indent_to_block(text: String, amount: int) -> String:
	var _output := ""
	var _t = text.split("\n")
	for _line in _t:
		for _i in amount: _output += INDENT # add the actual indent
		_output += _line + "\n"
	_output = _output.strip_edges(false, true) # remove the newline from the right
	return(_output)

# Useful shortcut to add tags, indentation, etc
func fmt(string: String, level := 0, tag := "") -> String:
	var _s := ""
	for _l in level:
		_s += TextUtils.INDENT
	if tag != "": _s += "<" + tag + ">"
	_s += string
	if tag != "": _s += "</" + tag + ">"
	_s += "\n"
	return(_s)

func add_line_to_template(text: String, template: String, marker: String) -> String:
	var output := ""
	for _line in template.split("\n"):
		if marker in _line:
			var _ic := _line.count(TextUtils.INDENT)
			output += TextUtils.add_indent_to_block(text, _ic) + "\n"
		else:
			output += _line + "\n"
	output = output.strip_edges(false, true)
	return(output)
