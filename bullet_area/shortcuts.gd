extends Node

@export var object_script : Script
@export var camera : Camera2D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("action_duplicate"):
		var dupe = Node2D.new()
		dupe.set_script(object_script)
		dupe.attack = Bridge.selected_object.attack.copy()
		dupe.projectile = Bridge.selected_object.projectile.copy()
		dupe.object_settings = Bridge.selected_object.object_settings.copy()
		%ObjectContainer.add_child(dupe)
		Bridge.selected_object = dupe
	if event.is_action_pressed("action_delete"):
		if Bridge.selected_object:
			Bridge.selected_object.queue_free()
			Bridge.selected_object = null
	if event.is_action_pressed("action_add"):
		var obj = Node2D.new()
		obj.set_script(object_script)
		obj.object_settings.position = get_parent().get_local_mouse_position().snapped(Vector2(10, 10))
		%ObjectContainer.add_child(obj)
		Bridge.selected_object = obj
	if event.is_action_pressed("action_focus"):
		if Bridge.selected_object:
			camera.position = Bridge.selected_object.position
