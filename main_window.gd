extends CanvasLayer

func render_pages() -> void:
	# Generate pages
	if FileAccess.file_exists(Global.HTML_ROOT + "pages.txt"):
		var pages_file = FileAccess.open(Global.HTML_ROOT + "pages.txt", FileAccess.READ)
		var pages = pages_file.get_as_text().strip_edges().split("\n")
		pages_file.close()
		
		for page in pages:
			var data = page.split(",")
			print("Rendering page '" + data[0] + "'...")
			var _pr = load("res://renderer/page_renderer.gd").new()
			_pr.page_id = data[0]
			_pr.page_title = data[1]
			add_child(_pr)
			_pr.render()
	
	# Do cart separately as it goes in the products folder
	var _cart = load("res://renderer/page_renderer.gd").new()
	_cart.page_id = "_cart"
	_cart.output_folder = Global.HTML_ROOT + "products/"
	_cart.page_title = "Cart"
	add_child(_cart)
	_cart.render()

func _ready() -> void:
	var _list_dir = DirAccess.get_files_at(Global.CATEGORY_DATA_PATH)
	for _file in _list_dir:
		var _b = Button.new()
		_b.text = _file
		_b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		_b.pressed.connect(func():
			var _list = Global.generate_list(Global.CATEGORY_DATA_PATH + _file)
			var _category_editor = load(
				"res://ui/category_editor/category_editor.tscn").instantiate()
			_category_editor.list = _list
			_category_editor.category_id = _file.replace(".txt", "")
			get_tree().change_scene_to_node(_category_editor))
		$Box/VBox/CategoryList.add_child(_b)
	render_pages()

func _on_button_pressed() -> void:
	render_pages()
