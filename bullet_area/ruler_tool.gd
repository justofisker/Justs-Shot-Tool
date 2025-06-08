extends Node2D

var line_origin: Vector2
var pressed: bool = false

func _ready() -> void:
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	if Bridge.tool_mode != Bridge.ToolMode.Ruler:
		if pressed:
			pressed = false
			queue_redraw()
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			pressed = event.pressed
			if pressed:
				line_origin = get_local_mouse_position()
			queue_redraw()
	if event is InputEventMouseMotion:
		if pressed:
			queue_redraw()

func _draw_string(pos: Vector2, text: String, text_modulate: Color = Color.WHITE, shifted: bool = true) -> void:
	var zoom := get_viewport().get_camera_2d().zoom
	var default_font := ThemeDB.fallback_font
	var font_size := int(ThemeDB.fallback_font_size * get_window().content_scale_factor)
	var mat := Transform2D.IDENTITY.scaled(Vector2.ONE / zoom)
	if shifted:
		mat = mat.translated_local(Vector2(0, font_size / 2))
	var width := default_font.get_string_size(text).x
	draw_set_transform_matrix(mat.translated(pos).translated_local(Vector2(-width / 2, 0)))
	draw_string_outline(default_font, Vector2.ZERO, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 3, Color.BLACK)
	draw_string(default_font, Vector2.ZERO, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_modulate)

static func float_to_string(a: float) -> String:
	return ("%.2f" % a).trim_suffix("0").trim_suffix(".0")

func _draw() -> void:
	if pressed:
		var mouse_pos := get_local_mouse_position()
		if line_origin.is_equal_approx(mouse_pos):
			var pos := line_origin / 8.0
			_draw_string(line_origin, "(%s, %s)" % [ float_to_string(pos.x), float_to_string(pos.y) ], Color.WHITE, false)
			return
		var mid_point := Vector2(line_origin.x, mouse_pos.y)
		var color := Color.SKY_BLUE
		var draw_secondary := absf(fposmod(line_origin.angle_to_point(mouse_pos) + PI / 4, PI / 2) - PI / 4) > deg_to_rad(2)
		draw_line(line_origin, mouse_pos, color, 4 / get_viewport().get_camera_2d().zoom.x)
		if draw_secondary:
			draw_line(line_origin, mid_point, color)
			draw_line(mid_point, mouse_pos, color)
			_draw_string(mouse_pos, "%d°" %  roundi(rad_to_deg(absf(mouse_pos.angle_to_point(line_origin) - mouse_pos.angle_to_point(mid_point)))), Color.LIGHT_GRAY, false)
			_draw_string(line_origin, "%d°" %  roundi(rad_to_deg(absf(line_origin.angle_to_point(mouse_pos) - line_origin.angle_to_point(mid_point)))), Color.LIGHT_GRAY, false)
			_draw_string(line_origin.lerp(mid_point, 0.5), "%s tiles" % float_to_string(absf(line_origin.y - mid_point.y) / 8), Color.LIGHT_GRAY)
			_draw_string(mouse_pos.lerp(mid_point, 0.5), "%s tiles" % float_to_string(absf(mouse_pos.x - mid_point.x) / 8), Color.LIGHT_GRAY)
		_draw_string(line_origin.lerp(mouse_pos, 0.5), "%s tiles" % float_to_string(((line_origin - mouse_pos) / 8).length()))
