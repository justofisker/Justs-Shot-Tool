@tool
extends Label

func _ready() -> void:
	var line_edit := (get_parent() as LineEdit)
	line_edit.text_changed.connect(_on_text_changed)
	line_edit.focus_entered.connect(_on_focus_toggled.bind(true))
	line_edit.focus_exited.connect(_on_focus_toggled.bind(false))
	_on_text_changed.bind(line_edit.text).call_deferred()

func _on_focus_toggled(focused: bool):
	visible = !focused

func _on_text_changed(new_string: String) -> void:
	var offset := 10
	if text.begins_with("°"):
		offset = 4
	elif text.begins_with("%") || text == "x":
		offset = 6
	position.x = preload("res://font/Space_Mono/SpaceMono-Regular.ttf").get_string_size(new_string).x + offset
	size.x = get_parent_control().size.x - position.x
	size.y = get_parent_control().size.y
