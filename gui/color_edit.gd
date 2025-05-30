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

@export var label_override : String = "" :
	set(value):
		label_override = value
		if label:
			if label_override == "":
				label.text = name
			else:
				label.text = label_override

@export var enabled : bool = true :
	set(value):
		enabled = value
		if color_picker_button:
			color_picker_button.disabled = !enabled
		if check_box:
			check_box.set_pressed_no_signal(enabled)
		toggled.emit(enabled)

@export var toggleable : bool = false :
	set(value):
		toggleable = value
		if check_box:
			check_box.visible = toggleable

@onready var color_picker_button: ColorPickerButton = $ColorPickerButton
@onready var label: Label = $HBoxContainer/Label
@onready var check_box: CheckBox = $HBoxContainer/CheckBox

func _ready() -> void:
	renamed.connect(_on_renamed)
	_on_renamed()
	enabled = enabled
	color_picker_button.color = value
	check_box.visible = toggleable

func _on_renamed() -> void:
	if label_override == "":
		label.text = name
	else:
		label.text = label_override

func _on_check_box_toggled(toggled_on: bool) -> void:
	self.enabled = toggled_on

func _on_color_picker_button_color_changed(color: Color) -> void:
	self.value = color
