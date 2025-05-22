extends PanelContainer

func _on_select_pressed() -> void:
	Bridge.tool_mode = Bridge.ToolMode.Select

func _on_move_pressed() -> void:
	Bridge.tool_mode = Bridge.ToolMode.Move

func _on_ruler_pressed() -> void:
	Bridge.tool_mode = Bridge.ToolMode.Ruler

func _on_aim_pressed() -> void:
	Bridge.tool_mode = Bridge.ToolMode.Aim
