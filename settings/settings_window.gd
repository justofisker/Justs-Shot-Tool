extends Window

@export var settings_edit_container : VBoxContainer

func _ready() -> void:
	if OS.get_name() != "Web":
		var dpi_scale := Node.new()
		dpi_scale.set_script(preload("res://dpi_scale.gd"))
		add_child(dpi_scale)
	close_requested.connect(_on_close_requested)
	for child in settings_edit_container.get_children():
		var property := child.name.to_snake_case()
		if property in Settings:
			child.value = Settings.get(property)
		else:
			push_error("Unknown settings %s" % property)
		child.value_changed.connect(_value_changed.bind(property))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		queue_free()

func _on_close_requested() -> void:
	queue_free()

func _value_changed(value, property: String) -> void:
	Settings.set(property, value)
	Settings.setting_changed.emit(property)
