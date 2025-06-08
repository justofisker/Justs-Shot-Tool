extends PanelContainer

func _on_select_pressed() -> void:
	Bridge.tool_mode = Bridge.ToolMode.Select

func _on_move_pressed() -> void:
	Bridge.tool_mode = Bridge.ToolMode.Move

func _on_ruler_pressed() -> void:
	Bridge.tool_mode = Bridge.ToolMode.Ruler

func _on_aim_pressed() -> void:
	Bridge.tool_mode = Bridge.ToolMode.Aim

func _on_expand_toggled(toggled_on: bool) -> void:
	Bridge.property_inspector.visible = !toggled_on

func _on_add_pressed() -> void:
	Bridge.tool_mode = Bridge.ToolMode.Add

func _on_pan_pressed() -> void:
	Bridge.tool_mode = Bridge.ToolMode.Pan
