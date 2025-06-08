extends Node

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("action_duplicate"):
		if !Bridge.selected_object:
			return
		var dupe = Bridge.selected_object.copy()
		%ObjectContainer.add_child(dupe)
		Bridge.selected_object = dupe
	if event.is_action_pressed("action_delete"):
		if Bridge.selected_object:
			Bridge.selected_object.queue_free()
			Bridge.selected_object = null
	if event.is_action_pressed("action_add"):
		var obj = ShooterObject.new()
		obj.object_settings.position = get_parent().get_local_mouse_position().snapped(Vector2(8, 8)) / 8
		%ObjectContainer.add_child(obj)
		Bridge.selected_object = obj
	if event.is_action_pressed("action_focus"):
		if Bridge.selected_object:
			get_viewport().get_camera_2d().position = Bridge.selected_object.position
