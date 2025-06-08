extends Node

func _ready() -> void:
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	if Bridge.tool_mode == Bridge.ToolMode.Add && event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			var action = InputEventAction.new()
			action.pressed = true
			action.action = "action_add"
			Input.parse_input_event(action)
