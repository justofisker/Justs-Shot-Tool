extends Node2D

@onready var canvas_layer: CanvasLayer = $CanvasLayer

func _ready() -> void:
	var content_scale := get_window().content_scale_factor
	canvas_layer.scale = Vector2(content_scale, content_scale)
	get_viewport().get_camera_2d().zoom_mult = content_scale
	Settings.setting_changed.connect(_on_setting_changed)
	RenderingServer.set_default_clear_color(Settings.background_color)

func _on_setting_changed(property: String) -> void:
	if property == "background_color":
		RenderingServer.set_default_clear_color(Settings.background_color)
