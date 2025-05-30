extends Node2D

@onready var canvas_layer: CanvasLayer = $CanvasLayer

func _ready() -> void:
	var content_scale := get_window().content_scale_factor
	canvas_layer.scale = Vector2(content_scale, content_scale)
	get_viewport().get_camera_2d().zoom_mult = content_scale
	Settings.setting_changed.connect(_on_setting_changed)
	RenderingServer.set_default_clear_color(Settings.background_color)
	Bridge.bullet_area = self

func _on_setting_changed(property: String) -> void:
	if property == "background_color":
		RenderingServer.set_default_clear_color(Settings.background_color)

var pressed := false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if !event.button_mask & MOUSE_BUTTON_MASK_LEFT == MOUSE_BUTTON_MASK_LEFT:
			pressed = false
	if event is InputEventMouseButton:
		if !event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			pressed = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			pressed = true
