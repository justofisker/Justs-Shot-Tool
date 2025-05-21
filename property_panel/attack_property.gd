extends VBoxContainer

var attack := XMLObjects.Subattack.new() :
	set(value):
		attack = value
		if properties:
			for child in properties.get_children():
				var v = attack.get(child.name.to_snake_case())
				if v != null:
					child.set_block_signals(true)
					child.value = v
					child.set_block_signals(false)
				else:
					push_error("Unable to set value for " + child.name)

@export var properties: VBoxContainer
@export var properties_container: Control
@export var title: Label
@onready var title_format := title.text

func _ready() -> void:
	title.text = title_format % get_index()
	
	for child in properties.get_children():
		child.value_changed.connect(_set_property.bind(child.name.to_snake_case()))
		_set_property(child.value, child.name.to_snake_case())
		child.toggled.connect(_set_enabled.bind(child.name.to_snake_case()))

func _set_property(value, property: String) -> void:
	attack.set(property, value)
	attack.updated.emit()

func _set_enabled(toggled_on: bool, property: String) -> void:
	attack.set(property + "_enabled", toggled_on)
	attack.updated.emit()

func _on_collapse_pressed() -> void:
	properties_container.visible = !properties_container.visible

func _on_copy_button_pressed() -> void:
	if OS.get_name() == "Web":
		JavaScriptBridge.eval("window.copied_text = '%s'" % attack.to_xml().c_escape())
	else:
		DisplayServer.clipboard_set(attack.to_xml())

const ATTACK_PROPERTY = preload("res://property_panel/attack_property.tscn")
func _on_duplicate_pressed() -> void:
	var prop := ATTACK_PROPERTY.instantiate()
	prop.attack = attack.copy()
	get_parent().add_child(prop)
	get_parent().move_child(prop, get_index() + 1)

func _on_delete_pressed() -> void:
	queue_free()

func _on_move_up_pressed() -> void:
	var parent := get_parent()
	parent.move_child(self, clampi(get_index() - 1, 0, parent.get_child_count() - 1))

func _on_move_down_pressed() -> void:
	var parent := get_parent()
	parent.move_child(self, clampi(get_index() + 1, 0, parent.get_child_count() - 1))
