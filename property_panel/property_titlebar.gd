extends PanelContainer

@export var title : Label
@onready var title_format := title.text

func get_value_type_name() -> String:
	var value = get_parent().value
	if value is XMLObjects.Projectile:
		return "Projectile"
	if value is XMLObjects.Subattack:
		return "Subattack"
	push_error("Unknown value type")
	return ""

func _ready() -> void:
	get_parent().get_parent().child_order_changed.connect(_on_child_order_changed)
	_on_child_order_changed()

func _on_child_order_changed() -> void:
	title.text = title_format % [get_value_type_name(), get_parent().get_index()]

func _on_collapse_pressed() -> void:
	get_parent().toggle_property_visibility()

func _on_copy_button_pressed() -> void:
	if OS.get_name() == "Web":
		JavaScriptBridge.eval("window.copied_text = '%s'" % owner.value.to_xml().c_escape())
	else:
		DisplayServer.clipboard_set(owner.value.to_xml(owner.get_index()))

func _on_duplicate_pressed() -> void:
	var prop : Node = load(owner.scene_file_path).instantiate()
	prop.value = owner.value.copy()
	prop.properties_scene = owner.properties_scene
	owner.get_parent().add_child(prop)
	owner.get_parent().move_child(prop, owner.get_index() + 1)

func _on_delete_pressed() -> void:
	owner.queue_free()

func _on_move_up_pressed() -> void:
	var parent := owner.get_parent()
	parent.move_child(owner, clampi(owner.get_index() - 1, 0, parent.get_child_count() - 1))

func _on_move_down_pressed() -> void:
	var parent := owner.get_parent()
	parent.move_child(owner, clampi(owner.get_index() + 1, 0, parent.get_child_count() - 1))
