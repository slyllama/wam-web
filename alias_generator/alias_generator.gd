extends Node

signal finished

func _ready() -> void:
	var alias: Dictionary
	if !DirAccess.dir_exists_absolute(Global.PRODUCT_DATA_PATH): return
	for file_name in DirAccess.get_files_at(Global.PRODUCT_DATA_PATH):
		var file := FileAccess.open(Global.PRODUCT_DATA_PATH + file_name, FileAccess.READ)
		var file_data = JSON.parse_string(file.get_as_text())
		file.close()
		
		if "specifications" in file_data:
			var line_count := 0
			for line: String in file_data.specifications.split("\n"):
				var line_data = line.split(",")
				if line_count > 0:
					alias[line_data[0].to_lower()] = file_name.rstrip(".json")
				line_count += 1
	
	var alias_file := FileAccess.open(Global.DATA_ROOT + "live/scripts/code-aliases.js", FileAccess.WRITE)
	alias_file.store_string("codeAliases = " + JSON.stringify(alias) + ";")
	alias_file.close()
	
	Global.pconsole("Generated code aliases.")
	finished.emit()
