extends Node

@export var object_script : Script

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
		Bridge.selected_object.queue_free()
		Bridge.selected_object = null
	if event.is_action_pressed("action_add"):
		pass
	if event.is_action_pressed("action_focus"):
		pass
