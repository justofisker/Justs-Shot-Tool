extends Node2D

var timer: Timer

func _ready() -> void:
	var timer = Timer.new()
	timer.autostart = true
	timer.wait_time = 0.5
	timer.timeout.connect(_shoot)
	add_child(timer)

var inverted : bool = false
func _shoot() -> void:
	
	var angle_offset = deg_to_rad(attack.arc_gap * attack.num_projectiles / 2.0)
	for i in attack.num_projectiles:
		var node = Node2D.new()
		node.set_script(preload("res://projectile.gd"))
		node.proj = proj
		node.direction = get_local_mouse_position().angle() - angle_offset + deg_to_rad((i + 0.5) * attack.arc_gap)
		node.inverted = inverted
		add_child(node)
		inverted = !inverted

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

func _on_amplitude_value_changed(value: float) -> void:
	proj.amplitude = value

func _on_frequency_value_changed(value: float) -> void:
	proj.frequency = value

func _on_speed_clamp_value_changed(value: float) -> void:
	proj.speed_clamp = value

func _on_speed_clamp_enabled_toggled(toggled_on: bool) -> void:
	proj.speed_clamp_enabled = toggled_on

func _on_acceleration_value_changed(value: float) -> void:
	proj.acceleration = value

func _on_acceleration_delay_value_changed(value: float) -> void:
	proj.acceleration_delay = value

func _on_wavy_toggled(toggled_on: bool) -> void:
	proj.wavy = toggled_on
