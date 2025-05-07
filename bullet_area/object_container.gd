extends Node2D

const Projectile = preload("res://bullet_area/projectile.gd")
var projectiles : Array[Projectile]

func _ready() -> void:
	Bridge.set_deferred("selected_object", $Object)

func _process(delta: float) -> void:
	for proj in projectiles:
		proj.time_alive += delta
	queue_redraw()

var radius : float = 2
func _draw() -> void:
	for proj in projectiles:
		var elapsed : int = proj.time_alive * 1000
		var pos := proj.calculate_position(elapsed) * 8
		draw_circle(pos, radius * proj.proj.size / 100.0, Color.WHITE, false)
		var points : PackedVector2Array = []
		
		var delta = sin(PI / 16) * radius
		var arf = -cos(PI / 16) * radius
		points.push_back(Vector2(arf, delta))
		points.push_back(Vector2(radius / 3, delta))
		points.push_back(Vector2(arf, -delta))
		points.push_back(Vector2(radius / 3, -delta))
		
		# Head
		points.push_back(Vector2(radius, 0))
		points.push_back(Vector2(radius / 3, radius / 2))
		points.push_back(Vector2(radius, 0))
		points.push_back(Vector2(radius / 3, -radius / 2))
		points.push_back(Vector2(radius / 3, -radius / 2))
		points.push_back(Vector2(radius / 3, -delta))
		points.push_back(Vector2(radius / 3, radius / 2))
		points.push_back(Vector2(radius / 3, delta))
		
		for i in points.size():
			points[i] = points[i].rotated(proj.get_angle(elapsed)) * proj.proj.size / 100.0 + pos
		
		draw_multiline(points, Color.WHITE)
