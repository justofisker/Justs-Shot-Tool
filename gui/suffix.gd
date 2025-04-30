@tool
extends Label

func _ready() -> void:
	var line_edit := (get_parent() as LineEdit)
	line_edit.text_changed.connect(_on_text_changed)
	line_edit.focus_entered.connect(_on_focus_toggled.bind(true))
	line_edit.focus_exited.connect(_on_focus_toggled.bind(false))
	_on_text_changed(line_edit.text)

func _on_focus_toggled(focused: bool):
	visible = !focused

func _on_text_changed(new_string: String) -> void:
	var offset := 10
	if text.begins_with("°") || text.begins_with("%"):
		offset = 5
	position.x = get_theme_default_font().get_string_size(new_string).x + offset
	
