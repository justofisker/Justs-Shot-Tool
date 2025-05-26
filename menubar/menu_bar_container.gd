extends PanelContainer

@onready var menu_bar: MenuBar = $MenuBar

@export var settings_window_scene : PackedScene
var settings_window : Node = null

func _ready() -> void:
	if menu_bar.is_native_menu():
		theme_type_variation = "" 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("settings"):
		if !is_instance_valid(settings_window):
			settings_window = settings_window_scene.instantiate()
			add_child(settings_window)
