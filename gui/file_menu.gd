extends Node

@export var scene_manager: Node
@export var popup_menu: PopupMenu
const ShooterObject = preload("res://bullet_area/shooter_object.gd")

var current_file := "" :
	set(value):
		current_file = value
		get_window().title = "RotMG Shot Visualizer (%s)" % current_file.get_file()

func _ready() -> void:
	popup_menu.index_pressed.connect(_on_file_index_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("scene_new"):
		_on_file_index_pressed(0)
	if event.is_action_pressed("scene_save"):
		_on_file_index_pressed(1)
	if event.is_action_pressed("scene_save_as"):
		_on_file_index_pressed(2)
	if event.is_action_pressed("scene_load"):
		_on_file_index_pressed(3)

func _on_file_index_pressed(index: int) -> void:
	match index:
		0: # New
			Bridge.clear_objects()
			Bridge.clear_projectiles()
			var shooter = Node2D.new()
			shooter.set_script(ShooterObject)
			Bridge.object_container.add_child(shooter)
			Bridge.selected_object = shooter
		1: # Save
			if current_file == "":
				_on_file_index_pressed(2)
			else:
				_on_save_file_selected(current_file)
		2: # Save as
			var dialog = NativeFileDialog.new()
			dialog.clear_filters()
			dialog.add_filter("*.xml", "XML File")
			add_child(dialog)
			dialog.show()
			dialog.file_selected.connect(_on_save_file_selected)
			dialog.file_selected.connect(func(_path: String): dialog.queue_free())
			dialog.canceled.connect(dialog.queue_free)
		3: # Load
			var dialog = NativeFileDialog.new()
			dialog.clear_filters()
			dialog.add_filter("*.xml", "XML File")
			dialog.file_mode = NativeFileDialog.FILE_MODE_OPEN_FILE
			add_child(dialog)
			dialog.show()
			dialog.file_selected.connect(_on_load_file_selected)
			dialog.file_selected.connect(func(_path: String): dialog.queue_free())
			dialog.canceled.connect(dialog.queue_free)

func _on_save_file_selected(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(scene_manager.get_scene_xml())
	current_file = path

func _on_load_file_selected(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	scene_manager.load_scene_xml(file.get_buffer(file.get_length()))
	current_file = path
