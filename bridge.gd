extends Node

signal tool_mode_changed(mode: ToolMode)

enum ToolMode { Select, Move, Ruler, Aim, Add, Pan }

var tool_mode : ToolMode  = ToolMode.Aim :
	set(value):
		tool_mode = value
		tool_mode_changed.emit(tool_mode)

signal object_selected(old_object: Node2D, object: Node2D)

var object_container : Node = null
var projectile_container : Node = null
var bullet_area : Node = null
var property_inspector : Control = null

var selected_object : ShooterObject = null :
	set(value):
		if selected_object:
			selected_object.selected = false
		var old_object = selected_object
		selected_object = value
		if selected_object:
			selected_object.selected = true
		object_selected.emit(old_object, selected_object)

func get_object(type: int) -> ShooterObject:
	for child: ShooterObject in object_container.get_children():
		if child.object_settings.type == type:
			return child
	return null

func clear_objects() -> void:
	for child in object_container.get_children():
		object_container.remove_child(child)
		child.queue_free()

func clear_projectiles() -> void:
	for child in projectile_container.get_children():
		projectile_container.remove_child(child)
		child.queue_free()
