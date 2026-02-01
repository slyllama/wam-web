extends Node

# Renders a single page, baking it into a template

@export var page_id: String
@export var page_title: String
@export var output_folder: String = Global.PAGES_ROOT

func render() -> void:
	var source_path = Global.HTML_ROOT + "_" + page_id + ".html"
	if !FileAccess.file_exists(source_path):
		print("No page source found for '" + page_id + "', skipping this one.")
		queue_free()
		return
	
	var source = Global.splice_file_into_template(
		source_path, Global.product_html_template, "$CONTENT")
	var output_file = FileAccess.open(output_folder + page_id + ".html", FileAccess.WRITE)
	output_file = output_file
	output_file.store_string(source.replace("$TITLE", page_title))
	output_file.close()
	
	queue_free()
