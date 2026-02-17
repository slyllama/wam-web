extends CanvasLayer

func render_pages() -> void:
	# Generate pages
	Global.pconsole("Rendering pages.")
	if FileAccess.file_exists(Global.DATA_ROOT + "pages.txt"):
		var pages_file = FileAccess.open(Global.DATA_ROOT + "pages.txt", FileAccess.READ)
		var pages = pages_file.get_as_text().strip_edges().split("\n")
		pages_file.close()
		
		for page in pages:
			var data = page.split(",")
			Global.pconsole(" * Rendering page '" + data[0] + "'.")
			var _pr = load("res://renderer/page_renderer.gd").new()
			_pr.page_id = data[0]
			_pr.page_title = data[1]
			add_child(_pr)
			_pr.render()
	
	# Do cart separately as it goes in the products folder
	var _cart = load("res://renderer/page_renderer.gd").new()
	_cart.page_id = "cart"
	_cart.output_folder = Global.PAGES_ROOT
	_cart.page_title = "Enquiry Cart"
	add_child(_cart)
	_cart.render()

func render_categories() -> void:
	Global.pconsole("Generating category list.")
	for _n: Node in %CategoryList.get_children():
		_n.queue_free()
	var _list_dir = DirAccess.get_files_at(Global.CATEGORY_DATA_PATH)
	for _file in _list_dir:
		var _b = Button.new()
		_b.text = _file
		_b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		_b.flat = true
		_b.theme_type_variation = "ListButton"
		_b.pressed.connect(func():
			var _list = Global.generate_list(Global.CATEGORY_DATA_PATH + _file)
			var _category_editor = load(
				"res://ui/category_editor/category_editor.tscn").instantiate()
			_category_editor.list = _list
			_category_editor.category_id = _file.replace(".txt", "")
			get_tree().change_scene_to_node(_category_editor))
		%CategoryList.add_child(_b)

func _ready() -> void:
	get_window().size.x = floori(400.0 * get_window().content_scale_factor)
	render_categories()
	Global.pconsole("Ready.")

func _on_button_pressed() -> void:
	render_pages()

func _on_refresh_categories_pressed() -> void:
	render_categories()

func _on_ra_button_pressed() -> void:
	%RenderAll.render_all()
	render_pages()

func _on_open_data_folder_pressed() -> void:
	OS.shell_open(OS.get_user_data_dir())

func _on_gen_code_aliases_pressed() -> void:
	var code_alias_generator = load("res://alias_generator/alias_generator.tscn").instantiate()
	add_child(code_alias_generator)
	
	await code_alias_generator.finished
	code_alias_generator.queue_free()
