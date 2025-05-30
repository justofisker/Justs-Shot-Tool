extends PopupMenu

enum Action { Settings, NewScene, SaveScene, SaveSceneAs, OpenScene, Import }

func _ready() -> void:
	add_action_item("Settings", Action.Settings, "settings")
	add_separator()
	add_action_item("New Scene", Action.NewScene, "scene_new")
	add_action_item("Save Scene", Action.SaveScene, "scene_save")
	add_action_item("Save Scene As", Action.SaveSceneAs, "scene_save_as")
	add_action_item("Open Scene", Action.OpenScene, "scene_load")
	add_separator()
	add_action_item("Import Objects", Action.Import, "file_import")

func add_action_item(label: String, id: int, action_name: StringName) -> void:
	var event := InputEventAction.new()
	event.pressed = true
	event.action = action_name
	var events := InputMap.action_get_events(action_name)
	add_item(label, id)
	var shortcut := Shortcut.new()
	shortcut.events = events
	set_item_shortcut(item_count - 1, shortcut)
