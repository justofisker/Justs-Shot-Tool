extends Node

@export var scene_manager: Node
@export var popup_menu: PopupMenu
const ShooterObject = preload("res://bullet_area/shooter_object.gd")

func _ready() -> void:
	if OS.get_name() != "Web":
		queue_free()
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
		1, 2: # Save
			JavaScriptBridge.download_buffer(scene_manager.get_scene_xml().to_utf8_buffer(), "scene.xml", "application/xml")
		3: # Load
			var dialog = HTML5FileDialog.new()
			dialog.file_mode = HTML5FileDialog.FileMode.OPEN_FILE
			dialog.filters.push_back("application/xml")
			add_child(dialog)
			dialog.show()
			dialog.file_selected.connect(_on_load_file_selected)

func _on_load_file_selected(file: HTML5FileHandle) -> void:
	scene_manager.load_scene_xml(await file.as_buffer())
