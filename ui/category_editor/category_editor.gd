extends Panel

const CategoryRenderer = preload("res://renderer/category_renderer.gd")

@export var list: String
@export var category_id: String

func _ready() -> void:
	#var _list = Global.generate_list(Global.CATEGORY_DATA_PATH + "rubber_hose.txt")
	%List.id_list = list
	%List.populate()

func _on_list_id_clicked(id: String) -> void:
	%Product.id = id
	%Product.populate()

func _on_new_product_box_new_product_created(id: String) -> void:
	%Product.id = id
	%Product.populate()
	%List.populate()

func _on_new_product_box_new_product_duplicate(id: String) -> void:
	%Product.id = id
	%Product.populate(false)
	%List.populate()

func _on_refresh_list_pressed() -> void:
	%List.populate()

func _on_product_saved() -> void:
	%List.populate()

func _on_render_category_pressed() -> void:
	Global.load_category_html_template()
	
	%List.id_list = list
	%List.populate()
	
	var _cr = CategoryRenderer.new()
	_cr.id_list = Global.generate_list(Global.CATEGORY_DATA_PATH + category_id + ".txt", true)
	
	_cr.category_id = category_id
	_cr.category_title = "Rubber Hoses"
	
	add_child(_cr)
	await get_tree().process_frame
	_cr.queue_free()

func _on_category_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://main_window.tscn")
