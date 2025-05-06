extends Node2D

@onready var canvas_layer: CanvasLayer = $CanvasLayer

func _ready() -> void:
	var scale := get_window().content_scale_factor
	canvas_layer.scale = Vector2(scale, scale)
	get_viewport().get_camera_2d().zoom_mult = scale
