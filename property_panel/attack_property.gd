extends VBoxContainer

signal updated()

@onready var collapse: TextureButton = $HBoxContainer/Collapse
@onready var properties: VBoxContainer = $Properties

var attack := XMLObjects.Subattack.new()

func _ready() -> void:
	collapse.pressed.connect(_on_collapse_pressed)
	updated.emit()

func _on_collapse_pressed() -> void:
	properties.visible = !properties.visible
	updated.emit()

func _on_projectile_id_value_changed(value: float) -> void:
	attack.projectile_id = int(value)
	updated.emit()

func _on_num_projectiles_value_changed(value: float) -> void:
	attack.num_projectiles = int(value)
	updated.emit()

func _on_rate_of_fire_value_changed(value: float) -> void:
	attack.rate_of_fire = value
	updated.emit()

func _on_pos_offset_value_changed(value: Vector2) -> void:
	attack.pos_offset = value
	updated.emit()
	
func _on_arc_gap_value_changed(value: float) -> void:
	attack.arc_gap = int(value)
	updated.emit()

func _on_default_angle_value_changed(value: float) -> void:
	attack.default_angle = int(value)
	updated.emit()
