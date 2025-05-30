extends Node

const FileMenubar = preload("res://menubar/file_menubar.gd")

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
				_on_save_file_selected(current_file)
		FileMenubar.Action.OpenScene:
			var dialog = NativeFileDialog.new()
			dialog.clear_filters()
			dialog.add_filter("*.xml", "XML File")
			dialog.file_mode = NativeFileDialog.FILE_MODE_OPEN_FILE
			add_child(dialog)
			dialog.show()
			dialog.file_selected.connect(_on_load_file_selected)
			dialog.file_selected.connect(func(_path: String): dialog.queue_free())
			dialog.canceled.connect(dialog.queue_free)

func save_as() -> void:
	var dialog = NativeFileDialog.new()
	dialog.clear_filters()
	dialog.add_filter("*.xml", "XML File")
	add_child(dialog)
	dialog.show()
	dialog.file_selected.connect(_on_save_file_selected)
	dialog.file_selected.connect(func(_path: String): dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)

func _on_save_file_selected(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(%SceneManager.get_scene_xml())
	current_file = path

func _on_load_file_selected(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	%SceneManager.load_scene_xml(file.get_buffer(file.get_length()))
	current_file = path
