extends Node2D

@onready var camera: Camera2D = get_viewport().get_camera_2d()
@export var grid_size := Vector2(8, 8)
@export var color := Color(0.8, 0.8, 0.8, 0.1)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if !Settings.grid_enabled:
		return
	
	var vp_size := get_viewport_rect().size / 2.0
	var cam_pos := camera.global_position
	
	draw_set_transform(cam_pos.snapped(grid_size) + grid_size / 2.0)
	for x in range(snappedf(-vp_size.x / 2, grid_size.x), snappedf(vp_size.x / 2, grid_size.x), grid_size.x):
		draw_line(Vector2(x, -vp_size.y / 2 - grid_size.y / 2), Vector2(x, vp_size.y / 2), Settings.grid_color)
	for y in range(snappedf(-vp_size.y / 2, grid_size.y), snappedf(vp_size.y / 2, grid_size.y), grid_size.y):
		draw_line(Vector2(-vp_size.x / 2 - grid_size.x / 2, y), Vector2(vp_size.x / 2, y), Settings.grid_color)
