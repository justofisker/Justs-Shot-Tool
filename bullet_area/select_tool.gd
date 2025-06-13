extends Node2D

var pressed : bool = false
var box_origin : Vector2

func _ready() -> void:
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	if Bridge.tool_mode != Bridge.ToolMode.Select:
		if pressed:
			pressed = false
			queue_redraw()
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				pressed = true
				box_origin = get_local_mouse_position()
			elif pressed:
				pressed = false
				var area = Rect2(box_origin, get_local_mouse_position() - box_origin).abs()
				
				var selected: Node2D = null
				for object: Node2D in %ObjectContainer.get_children():
					if area.has_point(object.position):
						selected = object
						break
				if selected:
					Bridge.selected_object = selected
				
				queue_redraw()

func _process(_delta: float) -> void:
	if pressed:
		queue_redraw()

func _draw() -> void:
	if pressed:
		var area = Rect2(box_origin, get_local_mouse_position() - box_origin).abs()
		draw_rect(area, Color(Color.SKY_BLUE, 0.5))
		draw_rect(area, Color.SKY_BLUE, false)
