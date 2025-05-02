extends Node

@export var move_gizmo_script : Script

func _ready() -> void:
	Bridge.object_selected.connect(_on_object_selected)
	Bridge.tool_mode_changed.connect(_on_tool_mode_changed)

func _on_object_selected(old_object: Node2D, object: Node2D) -> void:
	if Bridge.tool_mode == Bridge.ToolMode.Move:
		if old_object:
			for child in old_object.get_children():
				if child.get_script() == move_gizmo_script:
					old_object.remove_child(child)
					break
		if object:
			var move_gizmo = Node2D.new()
			move_gizmo.set_script(move_gizmo_script)
			object.add_child(move_gizmo)

func _on_tool_mode_changed(mode: Bridge.ToolMode):
	if !Bridge.selected_object:
		return
	
	for child in Bridge.selected_object.get_children():
		if child is not Timer:
			Bridge.selected_object.remove_child(child)
	
	if mode == Bridge.ToolMode.Move:
		var move_gizmo = Node2D.new()
		move_gizmo.set_script(move_gizmo_script)
		Bridge.selected_object.add_child(move_gizmo)
