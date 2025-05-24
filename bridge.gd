extends Node

signal tool_mode_changed(mode: ToolMode)

enum ToolMode { Select, Move, Ruler, Aim }

var tool_mode : ToolMode  = ToolMode.Select :
	set(value):
		tool_mode = value
		tool_mode_changed.emit(tool_mode)

signal object_selected(old_object: Node2D, object: Node2D)

var object_container : Node = null

var selected_object : Node = null :
	set(value):
		if selected_object:
			selected_object.selected = false
		var old_object = selected_object
		selected_object = value
		if selected_object:
			selected_object.selected = true
		object_selected.emit(old_object, selected_object)
