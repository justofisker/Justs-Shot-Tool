@tool
extends HBoxContainer

signal text_changed(value: String)

@export var title: String = "StringEdit" :
	set(value):
		title = value
		if is_instance_valid(label):
			label.text = title

@export var text : String = "" :
	set(value):
		text = value
		if is_instance_valid(line_edit):
			line_edit.text = text

@export var placeholder_text : String = "" :
	set(value):
		placeholder_text = value
		if is_instance_valid(line_edit):
			line_edit.placeholder_text = placeholder_text

@onready var line_edit: LineEdit = $PanelContainer/LineEdit
@onready var label: Label = $Title

func _ready() -> void:
	label.text = title
	line_edit.text = text
	line_edit.placeholder_text = placeholder_text
