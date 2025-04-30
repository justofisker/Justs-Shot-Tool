extends VBoxContainer

signal updated()

var proj := XMLObjects.Projectile.new()

func _on_object_id_text_changed(value: String) -> void:
	proj.object_id = value
	updated.emit()

func _on_type_value_changed(value: float) -> void:
	proj.type = int(value)
	updated.emit()

func _on_lifetime_ms_value_changed(value: float) -> void:
	proj.lifetime_ms = int(value)
	updated.emit()

func _on_size_value_changed(value: float) -> void:
	proj.size = int(value)
	updated.emit()

func _on_speed_value_changed(value: float) -> void:
	proj.speed = int(value)
	updated.emit()

func _on_acceleration_value_changed(value: float) -> void:
	proj.acceleration = value
	updated.emit()

func _on_speed_clamp_toggled(enabled: bool) -> void:
	proj.speed_clamp_enabled = enabled
	updated.emit()

func _on_speed_clamp_value_changed(value: float) -> void:
	proj.speed_clamp = int(value)
	updated.emit()

func _on_acceleration_delay_value_changed(value: float) -> void:
	proj.acceleration_delay = int(value)
	updated.emit()

func _on_amplitude_value_changed(value: float) -> void:
	proj.amplitude = value
	updated.emit()

func _on_frequency_value_changed(value: float) -> void:
	proj.frequency = value
	updated.emit()

func _on_circle_turn_delay_value_changed(value: float) -> void:
	proj.circle_turn_delay = int(value)
	updated.emit()

func _on_circle_turn_angle_value_changed(value: float) -> void:
	proj.circle_turn_angle = value
	updated.emit()

func _on_turn_rate_value_changed(value: float) -> void:
	proj.turn_rate = int(value)
	updated.emit()

func _on_turn_rate_delay_value_changed(value: float) -> void:
	proj.turn_rate_delay = int(value)
	updated.emit()

func _on_turn_stop_time_value_changed(value: float) -> void:
	proj.turn_stop_time = int(value)
	updated.emit()

func _on_turn_acceleration_value_changed(value: float) -> void:
	proj.turn_accerlation = value
	updated.emit()

func _on_turn_acceleration_delay_value_changed(value: float) -> void:
	proj.turn_accerlation_delay = int(value)
	updated.emit()

func _on_turn_clamp_value_changed(value: float) -> void:
	proj.turn_clamp = int(value)
	updated.emit()
