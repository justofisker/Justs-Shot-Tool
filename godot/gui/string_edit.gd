@tool
extends HBoxContainer

signal value_changed(value: String)
signal toggled(toggle_on: bool)

@export var title: String = "StringEdit" :
	set(value):
		title = value
		if label:
			label.text = title

@export var value : String = "" :
	set(new_value):
		value = new_value
		if line_edit && line_edit.text != value:
			line_edit.text = value
		value_changed.emit(value)

@export var placeholder_text : String = "" :
	set(value):
		placeholder_text = value
		if line_edit:
			line_edit.placeholder_text = placeholder_text

@export var enabled : bool = true :
	set(value):
		enabled = value
		if line_edit:
			if enabled:
				line_edit.mouse_default_cursor_shape = Control.CURSOR_IBEAM
				line_edit.selecting_enabled = true
				line_edit.focus_mode = Control.FOCUS_ALL
			else:
				line_edit.mouse_default_cursor_shape = Control.CURSOR_ARROW
				line_edit.selecting_enabled = false
				line_edit.focus_mode = Control.FOCUS_NONE
			toggled.emit(enabled)

@export var toggleable : bool = false :
	set(value):
		toggleable = value
		if check_box:
			check_box.visible = toggleable

@onready var check_box: CheckBox = $HBoxContainer/CheckBox
@onready var label: Label = $HBoxContainer/Title
@onready var line_edit: LineEdit = $PanelContainer/LineEdit

func _on_toggled(toggled_on: bool) -> void:
	self.enabled = toggled_on
	line_edit.editable = enabled

func _ready() -> void:
	check_box.visible = toggleable
	check_box.toggled.connect(_on_toggled)
	if toggleable:
		line_edit.editable = enabled
	
	label.text = title
	line_edit.text = value
	line_edit.placeholder_text = placeholder_text
	
func _on_line_edit_text_changed(new_text: String) -> void:
	self.value = new_text

func _on_line_edit_text_submitted(new_text: String) -> void:
	self.value = new_text
