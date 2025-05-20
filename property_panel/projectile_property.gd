extends VBoxContainer

var projectile := XMLObjects.Projectile.new() :
	set(value):
		projectile = value
		if properties:
			for child in properties.get_children():
				if child is HSeparator:
					continue
				var v = projectile.get(child.name.to_snake_case())
				if v != null:
					child.set_block_signals(true)
					child.value = v
					child.set_block_signals(false)
				else:
					push_error("Unable to set value for " + child.name)

@export var properties: VBoxContainer

func _ready() -> void:
	for child in properties.get_children():
		if child is HSeparator:
			continue
		child.value_changed.connect(_set_property.bind(child.name.to_snake_case()))
		_set_property(child.value, child.name.to_snake_case())
		child.toggled.connect(_set_enabled.bind(child.name.to_snake_case()))

func _set_property(value, property: String) -> void:
	projectile.set(property, value)
	projectile.updated.emit()

func _set_enabled(toggled_on: bool, property: String) -> void:
	projectile.set(property + "_enabled", toggled_on)
	projectile.updated.emit()

func _on_collapse_pressed() -> void:
	properties.visible = !properties.visible

func _on_copy_button_pressed() -> void:
	DisplayServer.clipboard_set(projectile.to_xml())
	if OS.get_name() == "Web":
		JavaScriptBridge.eval("window.copied_text = '%s'" % projectile.to_xml())
