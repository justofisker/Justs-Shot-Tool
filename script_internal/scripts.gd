extends PopupMenu

var scripts : Array[Script]

func _ready() -> void:
	var submenu := PopupMenu.new()
	
	var dir = DirAccess.open("res://scripts/")
	
	for script_file in dir.get_files():
		if !script_file.ends_with(".gd") && !script_file.ends_with(".gdc"):
			continue
		
		var script : Script = load("res://scripts/" + script_file)
		
		if script.get_base_script() != BaseScript:
			push_error("Error loading script: %s", script_file)
			continue
		
		var info : Dictionary = script.get_script_constant_map()["info"]
		
		submenu.add_item("%s (%s.gd)" % [ info["name"], script_file.get_basename() ])
		scripts.push_back(script)
	
	submenu.index_pressed.connect(_on_run_index_pressed)
	
	add_submenu_node_item("Run", submenu)
	add_separator()
	add_item("Rescan Scripts Folder")
	add_item("Open Scripts Folder")
	
	index_pressed.connect(_on_index_pressed)

func _on_index_pressed(index: int) -> void:
	match index:
		2: # Reload Script Folder
			pass
		3: # Open Script Folder
			OS.shell_show_in_file_manager("./scripts/")

func _on_run_index_pressed(index: int) -> void:
	var node := Node.new()
	node.set_script(scripts[index])
	add_child(node)
