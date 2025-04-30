@tool
extends HBoxContainer

signal value_changed(color: Color)
signal toggled(toggle_on: bool)

@export var value : Color = Color.WHITE :
	set(new_value):
		value = new_value
		if color_picker_button:
			color_picker_button.color = value
		value_changed.emit(value)

@export var text : String = "ColorEdit" :
	set(value):
		text = value
		if label:
			label.text = value

@export var enabled : bool = true :
	set(value):
		enabled = value
		if color_picker_button:
			color_picker_button.disabled = !enabled
		toggled.emit(enabled)

@onready var color_picker_button: ColorPickerButton = $ColorPickerButton
@onready var label: Label = $HBoxContainer/Label
@onready var check_box: CheckBox = $HBoxContainer/CheckBox

# TODO: Enabled not working on start and in Engine

func _ready() -> void:
	label.text = text
	self.enabled = enabled
	color_picker_button.color = value
	color_picker_button.disabled = !enabled

func _on_check_box_toggled(toggled_on: bool) -> void:
	self.enabled = toggled_on
