extends PopupMenu

func _ready() -> void:
	add_action_item("Settings", "settings")
	add_separator()
	add_action_item("New Scene", "scene_new")
	add_action_item("Save Scene", "scene_save")
	add_action_item("Save Scene As", "scene_save_as")
	add_action_item("Open Scene", "scene_load")
	index_pressed.connect(_on_index_pressed)

func _on_index_pressed(index: int) -> void:
	var event = get_item_metadata(index)
	if event is InputEventAction:
		Input.parse_input_event(event)

func add_action_item(label: String, action_name: StringName) -> void:
	var event := InputEventAction.new()
	event.pressed = true
	event.action = action_name
	var events := InputMap.action_get_events(action_name)
	if events.size() == 0:
		add_item(label)
	else:
		var shortcut := events[0].as_text().trim_suffix(" (Physical)")
		add_item("%s (%s)" % [ label, shortcut ])
	set_item_metadata(item_count - 1, event)
