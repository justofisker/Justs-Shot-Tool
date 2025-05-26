extends Window

var user_script : GDScript = null
var script_instance : Object = null

@export var properties: VBoxContainer

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		queue_free()

func _ready() -> void:
	close_requested.connect(_on_closed_requested)
	script_instance = user_script.new()
	for property in script_instance.get_property_list():
		if property["usage"] & (PROPERTY_USAGE_SCRIPT_VARIABLE | PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR) == (PROPERTY_USAGE_SCRIPT_VARIABLE | PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR):
			var edit = null
			match property["type"]:
				TYPE_INT:
					edit = preload("res://gui/edits/number_edit.tscn").instantiate()
					edit.number_type = edit.NumberType.INTEGER
				TYPE_FLOAT:
					edit = preload("res://gui/edits/number_edit.tscn").instantiate()
					edit.number_type = edit.NumberType.FLOAT
				TYPE_VECTOR2:
					edit = preload("res://gui/edits/vector_edit.tscn").instantiate()
				TYPE_COLOR:
					edit = preload("res://gui/edits/color_edit.tscn").instantiate()
				TYPE_BOOL:
					edit = preload("res://gui/edits/bool_edit.tscn").instantiate()
				TYPE_STRING:
					edit = preload("res://gui/edits/string_edit.tscn").instantiate()
				_:
					push_error("Unsupported type for %s: %s" % [ property["name"], type_string(property["type"]) ])
			if edit != null:
				edit.name = property["name"]
				edit.label_override = property["name"].to_pascal_case()
				edit.value = script_instance.get(property["name"])
				properties.add_child(edit)
	
	size.y = get_contents_minimum_size().y
	
	show()

func _on_closed_requested() -> void:
	queue_free()

func _on_run_button_pressed() -> void:
	for child in properties.get_children():
		script_instance.set(child.name, child.value)
	script_instance.run()
	queue_free()
