extends Node

const FileMenubar = preload("res://menubar/file_menubar.gd")
const IMPORT_WINDOW = preload("res://import_window/import_window.tscn")

var import_window : Node = null

func _ready() -> void:
	if OS.get_name() != "Web":
		queue_free()

func _on_file_id_pressed(id: int) -> void:
	match id:
		FileMenubar.Action.NewScene:
			Bridge.clear_objects()
			Bridge.clear_projectiles()
			var shooter = Node2D.new()
			shooter.set_script(ShooterObject)
			Bridge.object_container.add_child(shooter)
			Bridge.selected_object = shooter
		FileMenubar.Action.SaveScene, FileMenubar.Action.SaveSceneAs:
			JavaScriptBridge.download_buffer(%SceneManager.get_scene_xml().to_utf8_buffer(), "scene.xml", "application/xml")
		FileMenubar.Action.OpenScene:
			var dialog = HTML5FileDialog.new()
			dialog.file_mode = HTML5FileDialog.FileMode.OPEN_FILE
			dialog.filters.push_back("application/xml")
			add_child(dialog)
			dialog.show()
			dialog.file_selected.connect(_on_load_file_selected)
		FileMenubar.Action.Import:
			var dialog = HTML5FileDialog.new()
			dialog.file_mode = HTML5FileDialog.FileMode.OPEN_FILE
			dialog.filters.push_back("application/xml")
			add_child(dialog)
			dialog.show()
			dialog.file_selected.connect(_on_import_file_selected)

func _on_load_file_selected(file: HTML5FileHandle) -> void:
	%SceneManager.load_scene_xml(await file.as_buffer())
	
func _on_import_file_selected(file: HTML5FileHandle) -> void:
	if !is_instance_valid(import_window):
		import_window = IMPORT_WINDOW.instantiate()
		get_parent().add_child(import_window)
		import_window.open_file(await file.as_buffer())
