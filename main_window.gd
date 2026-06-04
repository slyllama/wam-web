extends CanvasLayer

const CAT_TITLE_ALIASES := {
	"airline.txt": "Airline Fittings",
	"al_fittings.txt": "Aluminium Camlocks and Fittings",
	"bandings_cable_ties.txt": "Bandings and Cable Ties",
	"bauer_assorted_fittings.txt": "Bauer and Assorted Fittings",
	"brass_fittings.txt": "Brass Camlocks and Fittings",
	"clips_clamps.txt": "Clips and Clamps",
	"composite_ss.txt": "Composite and Stainless Steel Hoses",
	"crimping_machines.txt": "Crimping Machines",
	"ducting_vacuum.txt": "Ducting and Vacuum Hoses",
	"engineering.txt": "Engineering Services",
	"expansion_joints.txt": "Expansion Joints",
	"featured.txt": "Featured Products",
	"galv_bs_fittings.txt": "Galvanised and Black Steel Fittings",
	"garden_fittings.txt": "Garden Fittings",
	"hose_accessories.txt": "Hose Accessories",
	"hose_slings.txt": "Hose Slings",
	"hyd_steel_adaptors.txt": "Hydraulic Steel Adaptors",
	"hyd_steel_fittings.txt": "Hydraulic Steel Fittings",
	"hydraulic_hose.txt": "Hydraulic Hoses",
	"nozzles.txt": "Nozzles",
	"plastic_chem_fittings.txt": "Plastic and Chemical Fittings",
	"plastic_hose.txt": "Plastic Hoses",
	"pumps.txt": "Pumps and Flowmeters",
	"pwash_fittings.txt": "Pressure Wash Fittings",
	"reels.txt": "Hose Reels",
	"rubber_hose.txt": "Rubber Hoses",
	"rubber_sheet.txt": "Rubber Sheet",
	"silicone_rubber_adaptors.txt": "Silicone and Rubber Adaptors",
	"speed_fittings.txt": "Speed Fittings",
	"ss_fittings.txt": "Stainless Steel Fittings",
	"storage_bins.txt": "Storage Bins",
	"strainers.txt": "Strainers",
	"tank_truck.txt": "Tank Truck Valves and Accessories",
	"v_belts.txt": "V-Belts",
	"valves_brass.txt": "Brass Valves",
	"valves_gas.txt": "Gas Valves",
	"valves_plastic.txt": "Plastic Valves",
	"valves_ss.txt": "Stainless Steel Valves",
	"valves_steel.txt": "Steel Valves"
}

func get_cat_title(file_name: String) -> String:
	var output := file_name
	if file_name in CAT_TITLE_ALIASES:
		output = CAT_TITLE_ALIASES[file_name]
	return(output)

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
		_b.text = get_cat_title(_file)
		_b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		_b.flat = true
		_b.set_theme_type_variation("ListButton")
		_b.pressed.connect(func():
			var _list = Global.generate_list(Global.CATEGORY_DATA_PATH + _file)
			var _category_editor = load(
				"res://ui/category_editor/category_editor.tscn").instantiate()
			_category_editor.list = _list
			_category_editor.category_id = _file.replace(".txt", "")
			get_tree().change_scene_to_node(_category_editor))
		%CategoryList.add_child(_b)

func _ready() -> void:
	if !Global.first_run:
		get_window().size.x = floori(900.0 * get_window().content_scale_factor)
		get_window().position = DisplayServer.screen_get_position() + Vector2i(40, 60)
		Global.first_run = true
	render_categories()
	Global.pconsole("Ready.")

func _on_button_pressed() -> void:
	render_pages()

func _on_refresh_categories_pressed() -> void:
	render_categories()

func _on_ra_button_pressed() -> void:
	%PleaseWait.visible = true
	for _i in 3: await get_tree().process_frame
	%RenderAll.render_all()
	render_pages()
	for _i in 3: await get_tree().process_frame
	%PleaseWait.visible = false

func _on_open_data_folder_pressed() -> void:
	OS.shell_open(OS.get_user_data_dir())

func _on_gen_code_aliases_pressed() -> void:
	var code_alias_generator = load("res://alias_generator/alias_generator.tscn").instantiate()
	add_child(code_alias_generator)
	
	await code_alias_generator.finished
	code_alias_generator.queue_free()
