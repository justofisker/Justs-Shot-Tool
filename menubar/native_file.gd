extends Node

const FileMenubar = preload("res://menubar/file_menubar.gd")
const IMPORT_WINDOW = preload("res://import_window/import_window.tscn")

var import_window : Node

func _ready() -> void:
	if OS.get_name() == "Web":
		queue_free()

var current_file := "" :
	set(value):
		current_file = value
		var window := get_parent().get_parent().get_window()
		if current_file == "":
			window.title = ProjectSettings.get_setting("application/config/name")
		else:
			window.title = "%s (%s)" % [ ProjectSettings.get_setting("application/config/name"), current_file.get_file() ]

func _on_file_id_pressed(id: int) -> void:
	match id:
		FileMenubar.Action.NewScene:
			current_file = ""
			Bridge.clear_objects()
			Bridge.clear_projectiles()
			var shooter = Node2D.new()
			shooter.set_script(ShooterObject)
			Bridge.object_container.add_child(shooter)
			Bridge.selected_object = shooter
		FileMenubar.Action.SaveSceneAs:
			save_as()
		FileMenubar.Action.SaveScene:
			if current_file == "":
				save_as()
			else:
				_on_save_file_selected(true, [current_file], 0)
		FileMenubar.Action.OpenScene:
			DisplayServer.file_dialog_show("Load Scene", "", "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, ["*.xml"], _on_load_file_selected)
		FileMenubar.Action.Import:
			DisplayServer.file_dialog_show("Import Objects", "", "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, ["*.xml"], _on_import_file_selected)

func save_as() -> void:
	DisplayServer.file_dialog_show("Save Scene", "", "scene.xml", false, DisplayServer.FILE_DIALOG_MODE_SAVE_FILE, ["*.xml"], _on_save_file_selected)

func _on_save_file_selected(status: bool, selected_paths: PackedStringArray, _selected_filter_index: int) -> void:
	if status:
		var path = selected_paths[0]
		var file = FileAccess.open(path, FileAccess.WRITE)
		file.store_string(%SceneManager.get_scene_xml())
		current_file = path

func _on_load_file_selected(status: bool, selected_paths: PackedStringArray, _selected_filter_index: int) -> void:
	if status:
		var path = selected_paths[0]
		var file := FileAccess.open(path, FileAccess.READ)
		%SceneManager.load_scene_xml(file.get_buffer(file.get_length()))
		current_file = path

func _on_import_file_selected(status: bool, selected_paths: PackedStringArray, _selected_filter_index: int) -> void:
	if status:
		var path = selected_paths[0]
		var file := FileAccess.open(path, FileAccess.READ)
		if !is_instance_valid(import_window):
			import_window = IMPORT_WINDOW.instantiate()
			get_parent().add_child(import_window)
			import_window.open_file(file.get_buffer(file.get_length()))
