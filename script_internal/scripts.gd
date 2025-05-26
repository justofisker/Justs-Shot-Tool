extends PopupMenu

var scripts : Array[Script]
var submenu : PopupMenu = PopupMenu.new()

@export var script_window : PackedScene

const SCRIPTS_FOLDER := "res://scripts/"

func _ready() -> void:
	scan_script_folder()
	submenu.index_pressed.connect(_on_run_index_pressed)
	
	add_submenu_node_item("Run", submenu)
	if OS.get_name() != "Web":
		add_separator()
		add_item("Rescan Scripts Folder")
		add_item("Open Scripts Folder")
	
	index_pressed.connect(_on_index_pressed)

func scan_script_folder() -> void:
	submenu.clear()
	scripts.clear()
	var dir_path = SCRIPTS_FOLDER
	if OS.get_name() != "Web":
		dir_path = ProjectSettings.globalize_path(dir_path)
	var dir = DirAccess.open(dir_path)
	for script_file in dir.get_files():
		var script : GDScript = null
		
		if script_file.ends_with(".gd"):
			script = GDScript.new()
			script.source_code = FileAccess.get_file_as_string(dir_path + script_file)
			script.reload()
		elif script_file.ends_with(".gdc"):
			script = load(SCRIPTS_FOLDER + script_file)
		else:
			continue
		
		if script.get_base_script() != BaseScript:
			push_error("Error loading script: %s" % script_file)
			continue
		
		var info : Dictionary = script.get_script_constant_map()["info"]
		
		submenu.add_item("%s (%s.gd)" % [ info["name"], script_file.get_basename() ])
		scripts.push_back(script)

func _on_index_pressed(index: int) -> void:
	match index:
		2: # Reload Script Folder
			scan_script_folder()
		3: # Open Script Folder
			OS.shell_show_in_file_manager(ProjectSettings.globalize_path(SCRIPTS_FOLDER))

func _on_run_index_pressed(index: int) -> void:
	var window = script_window.instantiate()
	window.user_script = scripts[index]
	window.title = submenu.get_item_text(index)
	get_parent().add_child(window)
