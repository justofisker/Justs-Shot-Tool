extends PanelContainer
@onready var attack_property: VBoxContainer = $ScrollContainer/MarginContainer/VBoxContainer/AttackProperty
@onready var projectile_property: VBoxContainer = $ScrollContainer/MarginContainer/VBoxContainer/ProjectileProperty
@onready var bullet_area: Control = $"../SubViewportContainer/SubViewport/BulletArea"

func _ready() -> void:
	bullet_area.attack = attack_property.attack
	bullet_area.projectile = projectile_property.proj

func _on_attack_property_updated() -> void:
	if bullet_area:
		bullet_area.attack = attack_property.attack

func _on_projectile_property_updated() -> void:
	if bullet_area:
		bullet_area.projectile = projectile_property.proj

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		grab_focus()
		release_focus()
