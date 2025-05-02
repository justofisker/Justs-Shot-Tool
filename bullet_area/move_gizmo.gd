extends Node2D

@export var length := 70
@export var triangle_size := Vector2(10, 15) 
@export var thickness = 2

func _process(_delta: float) -> void:
	var scalef = 1.0 / get_viewport().get_camera_2d().zoom.x
	scale = Vector2(scalef, scalef)
	queue_redraw()

func draw_triangle(angle: float, color: Color) -> void:
	draw_line(Vector2(), Vector2(0, -length).rotated(angle), color, thickness)
	draw_polygon([Vector2(-triangle_size.x, -length).rotated(angle), Vector2(0, -length - triangle_size.y).rotated(angle), Vector2(triangle_size.x, -length).rotated(angle)], [color])

func _draw() -> void:
	draw_triangle(PI / 2, Color.RED)
	draw_triangle(0, Color.GREEN)

enum Grab {X, Y, XY, NONE}

var grab := Grab.NONE
var grab_offset : Vector2

func _input(event: InputEvent) -> void:
	var y_grab_rect := Rect2(-triangle_size.x, -length - triangle_size.y, triangle_size.x * 2, triangle_size.y + length - triangle_size.x)
	var x_grab_rect := Rect2(triangle_size.x, -triangle_size.x, triangle_size.y + length - triangle_size.x, triangle_size.x * 2)
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				grab_offset = get_canvas_transform().affine_inverse() * event.position - global_position
				var pos = to_local(get_canvas_transform().affine_inverse() * event.position)
				if y_grab_rect.has_point(pos):
					grab = Grab.Y
				elif x_grab_rect.has_point(pos):
					grab = Grab.X
				else:
					grab = Grab.XY
			else:
				grab = Grab.NONE
	elif event is InputEventMouseMotion && grab != Grab.NONE:
		var current_pos = get_parent().global_position
		var pos : Vector2 = get_canvas_transform().affine_inverse() * event.position
		var parent = get_parent()
		if grab == Grab.X || grab == Grab.XY:
			get_parent().global_position.x = snappedf(pos.x - grab_offset.x, 10)
		if grab == Grab.Y || grab == Grab.XY:
			get_parent().global_position.y = snappedf(pos.y - grab_offset.y, 10)
		if !current_pos.is_equal_approx(get_parent().global_position):
			get_parent().object_settings.position = parent.global_position
			get_parent().object_settings.updated.emit()
