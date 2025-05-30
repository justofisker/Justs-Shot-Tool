extends PanelContainer

@onready var menu_bar: MenuBar = $MenuBar

func _ready() -> void:
	if menu_bar.is_native_menu():
		theme_type_variation = "" 
