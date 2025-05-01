extends VBoxContainer

signal updated()

var attack := XMLObjects.Subattack.new() :
	set(value):
		attack = value
		if properties:
			for child in properties.get_children():
				var v = attack.get(child.name.to_snake_case())
				if v != null:
					child.value = v
				else:
					push_error("Unable to set value for " + child.name)
		updated.emit()

@onready var collapse: TextureButton = $HBoxContainer/Collapse
@onready var properties: VBoxContainer = $Properties

func _ready() -> void:
	for child in properties.get_children():
		child.value_changed.connect(_set_property.bind(child.name.to_snake_case()))
		_set_property(child.value, child.name.to_snake_case())
		child.toggled.connect(_set_enabled.bind(child.name.to_snake_case()))

func _set_property(value, property: String) -> void:
	attack.set(property, value)

func _set_enabled(toggled_on: bool, property: String) -> void:
	attack.set(property + "_enabled", toggled_on)

func _on_collapse_pressed() -> void:
	properties.visible = !properties.visible

func _on_bullet_area_selected_shooter(node: Node2D) -> void:
	if !node:
		visible = false
		return
	else:
		visible = true
	self.attack = node.attack
