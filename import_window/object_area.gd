extends VBoxContainer

@export var object_list: VBoxContainer

func _on_select_none_pressed() -> void:
	for child: CheckBox in object_list.get_children():
		child.button_pressed = false

func _on_select_all_pressed() -> void:
	for child: CheckBox in object_list.get_children():
		child.button_pressed = true

func _on_line_edit_text_changed(new_text: String) -> void:
	for child: CheckBox in object_list.get_children():
		if new_text == "":
			child.visible = true
		else:
			child.visible = child.text.containsn(new_text)
