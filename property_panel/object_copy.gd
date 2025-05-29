extends Node

func _on_copy_button_pressed() -> void:
	var copy_string = ""
	
	for idx in Bridge.selected_object.attacks.size():
		copy_string += Bridge.selected_object.attacks[idx].to_xml(idx)
	for idx in Bridge.selected_object.projectiles.size():
		copy_string += Bridge.selected_object.projectiles[idx].to_xml(idx)
		
	if OS.get_name() == "Web":
		JavaScriptBridge.eval("window.copied_text = '%s'" % copy_string.c_escape())
	else:
		DisplayServer.clipboard_set(copy_string)
