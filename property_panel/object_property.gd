extends VBoxContainer

signal value_set(value)

var object_settings := XMLObjects.ObjectSettings.new() :
	set(value):
		object_settings = value
		value_set.emit(value)

var value :
	set(value):
		object_settings = value
	get():
		return object_settings
		
func _on_copy_button_pressed() -> void:
	pass
