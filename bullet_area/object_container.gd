extends Node2D

const Projectile = preload("res://bullet_area/projectile.gd")
var projectiles : Array[Projectile]

func _process(_delta: float) -> void:
	queue_redraw()

var radius : float = 2
func _draw() -> void:
	for proj in projectiles:
		var offset = Vector2(proj.position) + Vector2(0, proj.y_offset).rotated(proj.direction) + proj.origin
		draw_circle(offset, radius * proj.proj.size / 100.0, Color.WHITE, false)
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
			points[i] = points[i].rotated(proj.direction) * proj.proj.size / 100.0 + offset
		
		draw_multiline(points, Color.WHITE)

func _physics_process(delta: float) -> void:
	for proj in projectiles:
		proj._physics_process(delta)
