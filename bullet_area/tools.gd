extends PanelContainer

enum Mode { Select, Move, Ruler }

var mode := Mode.Select :
	set(value):
		mode = value
		
		for shooter in shooters.get_children():
			for child in shooter.get_children():
				if child is not Timer:
					shooter.remove_child(child)
		
		match mode:
			Mode.Move:
				if !bullet_area.shooter:
					return
				var move_gizmo = Node2D.new()
				move_gizmo.set_script(preload("res://bullet_area/move_gizmo.gd"))
				bullet_area.shooter.add_child(move_gizmo)

var select_pressed: bool = false
var select_origin: Vector2

@onready var shooters: Node2D = $"../../../Shooters"
@onready var bullet_area: Control = $"../../.."

func _input(event: InputEvent) -> void:
	match mode:
		Mode.Select:
			if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					select_pressed = true
					select_origin = shooters.get_canvas_transform().affine_inverse() * event.global_position
				else:
					if select_pressed:
						var area := Rect2(select_origin, shooters.get_local_mouse_position() - select_origin).abs()
						bullet_area.shooter = null
						for shooter in shooters.get_children():
							if area.has_point(shooter.position):
								bullet_area.shooter = shooter
								break
					select_pressed = false
			elif event is InputEventMouseMotion:
				if select_pressed:
					pass
		Mode.Move:
			pass
		Mode.Ruler:
			pass

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if select_pressed:
		draw_set_transform_matrix(shooters.get_canvas_transform())
		var area := Rect2(select_origin, shooters.get_local_mouse_position() - select_origin).abs()
		draw_rect(area, Color(Color.SKY_BLUE, 0.5))
		draw_rect(area, Color(Color.SKY_BLUE), false)

func _on_select_pressed() -> void:
	self.mode = Mode.Select

func _on_move_pressed() -> void:
	self.mode = Mode.Move

func _on_ruler_pressed() -> void:
	self.mode = Mode.Ruler
