@tool
extends HBoxContainer

signal value_changed(value)
signal toggled(enabled: bool)

@onready var line_edit: LineEdit = find_children("*", "LineEdit", true, true)[0]
@onready var label: Label = find_children("Title", "Label", true, true).pop_front()
@onready var label_suffix: Label = find_children("Suffix", "Label", true, true).pop_front()
@onready var check_box: CheckBox = find_children("CheckBox", "CheckBox", true, true).pop_front()
@onready var tooltip_icon: TextureRect = find_children("TooltipIcon", "TextureRect", true, true).pop_front()

enum NumberType {INTEGER, FLOAT}
@export var number_type: NumberType = NumberType.INTEGER

@export var label_override : String = "" :
	set(value):
		label_override = value
		if label:
			if label_override == "":
				label.text = name
			else:
				label.text = label_override

@export var suffix : String = "" :
	set(value):
		suffix = value
		if label_suffix:
			label_suffix.text = value

@export var value_int : int = 0
@export var value_float : float = 0.0

var value :
	set(new_value):
		if number_type == NumberType.INTEGER:
			value_int = snapped(new_value, step_int)
		else:
			value_float = snappedf(new_value, step_float)
		if line_edit:
			if number_type == NumberType.INTEGER:
				if display_as_hex:
					line_edit.text = "0x%x" % value_int
				else:
					line_edit.text = str(value_int)
			else:
				line_edit.text = ("%." + str(min(str(fmod(value_float, 1)).substr(2).length(), 3)) + "f") % value_float
			line_edit.text_changed.emit.bind(line_edit.text).call_deferred()
		value_changed.emit(value)
	get():
		if number_type == NumberType.INTEGER:
			return value_int
		else:
			return value_float

var step :
	get():
		if number_type == NumberType.INTEGER:
			return step_int
		else:
			return step_float

var step_modified :
	get():
		if number_type == NumberType.INTEGER:
			return step_modified_int
		else:
			return step_modified_float

@export var step_int : int = 1
@export var step_float : float = 0.001
@export var step_modified_int : int = 1
@export var step_modified_float : float = 1

@export var toggleable : bool = false :
	set(value):
		toggleable = value
		if check_box:
			check_box.visible = toggleable

@export var enabled : bool = true :
	set(value):
		enabled = value
		if line_edit:
			if enabled:
				line_edit.mouse_default_cursor_shape = Control.CURSOR_IBEAM
				line_edit.selecting_enabled = true
				line_edit.focus_mode = Control.FOCUS_ALL
				line_edit.editable = enabled
			else:
				line_edit.mouse_default_cursor_shape = Control.CURSOR_ARROW
				line_edit.selecting_enabled = false
				line_edit.focus_mode = Control.FOCUS_NONE
				line_edit.editable = enabled
		toggled.emit(enabled)

@export var display_as_hex : bool = false

@export_multiline var tooltip : String = "" :
	set(value):
		tooltip = value
		if tooltip_icon:
			tooltip_icon.visible = !(tooltip == "")

func _ready() -> void:
	if tooltip_icon:
		tooltip_icon.visible = !(tooltip == "")
		tooltip_icon.tooltip_text = tooltip
	if check_box:
		check_box.visible = toggleable
		check_box.toggled.connect(_on_toggled)
		if toggleable:
			line_edit.editable = enabled
	renamed.connect(_on_renamed)
	_on_renamed()
	if label_suffix:
		label_suffix.text = suffix
	enabled = enabled
	value = value
	line_edit.text_changed.emit.bind(line_edit.text).call_deferred()
	
	line_edit.focus_entered.connect(_on_line_edit_focused_entered)
	line_edit.focus_exited.connect(_on_line_edit_focus_exited)
	line_edit.text_submitted.connect(_on_line_edit_text_submitted)

func _on_renamed() -> void:
	if label:
		if label_override == "":
			label.text = name
		else:
			label.text = label_override

func _on_toggled(toggled_on: bool) -> void:
	self.enabled = toggled_on

func _on_line_edit_text_submitted(_new_text: String) -> void:
	line_edit.release_focus()

func _on_line_edit_focused_entered() -> void:
	if number_type == NumberType.FLOAT:
		line_edit.text = str(value)

func _on_line_edit_focus_exited() -> void:
	var expression = Expression.new()
	if expression.parse(line_edit.text) != OK:
		self.value = 0
	else:
		var result = expression.execute([], null, false, true)
		if result == null:
			self.value = 0
		elif number_type == NumberType.INTEGER:
			self.value = roundi(result)
		else:
			self.value = float(result)
	line_edit.text_changed.emit(line_edit.text)
