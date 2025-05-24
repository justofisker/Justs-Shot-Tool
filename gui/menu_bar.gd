extends MenuBar

@onready var scene_manager: Node = $File/SceneManager

func _on_file_index_pressed(index: int) -> void:
	match index:
		0: # New
			pass
		1: # Save
			if OS.get_name() == "Web":
				var dialog = HTML5FileDialog.new()
				dialog.filters.push_back(".xml")
				dialog.show()
				dialog.file_selected.connect(_on_web_save_file_selected)
			else:
				var dialog = NativeFileDialog.new()
				dialog.add_filter("*.xml", "XML")
				add_child(dialog)
				dialog.show()
				dialog.file_selected.connect(_on_save_file_selected)
				dialog.file_selected.connect(func(_path: String): dialog.queue_free())
				dialog.canceled.connect(dialog.queue_free)
		2: # Load
			if OS.get_name() == "Web":
				pass
			else:
				var dialog = NativeFileDialog.new()
				dialog.add_filter("*.xml", "XML")
				dialog.file_mode = NativeFileDialog.FILE_MODE_OPEN_FILE
				add_child(dialog)
				dialog.show()
				dialog.file_selected.connect(_on_load_file_selected)
				dialog.file_selected.connect(func(_path: String): dialog.queue_free())
				dialog.canceled.connect(dialog.queue_free)

func _on_web_save_file_selected(file: HTML5FileHandle) -> void:
	print(file)

func _on_save_file_selected(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(scene_manager.get_scene_xml())

func _on_web_load_file_selected(file: HTML5FileHandle) -> void:
	pass

func _on_load_file_selected(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	scene_manager.load_scene_xml(file.get_buffer(file.get_length()))
