extends Node2D

var timer: Timer

func _ready() -> void:
	var timer = Timer.new()
	timer.autostart = true
	timer.wait_time = 0.5
	timer.timeout.connect(_shoot)
	add_child(timer)

func _shoot() -> void:
	var node = Node2D.new()
	node.set_script(preload("res://projectile.gd"))
	node.proj = proj
	node.direction = get_local_mouse_position().angle()
	add_child(node)

# Attack

var attack := XMLObjects.Subattack.new()

func _on_num_projectiles_value_changed(value: float) -> void:
	attack.num_projectiles = value

func _on_arc_gap_value_changed(value: float) -> void:
	attack.arc_gap = value

func _on_rate_of_fire_value_changed(value: float) -> void:
	attack.rate_of_fire = value

func _on_pos_offset_x_value_changed(value: float) -> void:
	attack.pos_offset.x = value

func _on_pos_offset_y_value_changed(value: float) -> void:
	attack.pos_offset.y = value

# Projectile

var proj := XMLObjects.Projectile.new()

func _on_lifetime_ms_value_changed(value: float) -> void:
	proj.lifetime_ms = value

func _on_speed_value_changed(value: float) -> void:
	proj.speed = value
