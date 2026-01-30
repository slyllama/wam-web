extends CanvasLayer

func _ready() -> void:
	var _list_dir = DirAccess.get_files_at(Global.CATEGORY_DATA_PATH)
	for _file in _list_dir:
		var _b = Button.new()
		_b.text = _file
		_b.pressed.connect(func():
			var _list = Global.generate_list(Global.CATEGORY_DATA_PATH + _file)
			var _category_editor = load(
				"res://ui/category_editor/category_editor.tscn").instantiate()
			_category_editor.list = _list
			_category_editor.category_id = _file.replace(".txt", "")
			get_tree().change_scene_to_node(_category_editor))
		$Box/VBox/CategoryList.add_child(_b)
