extends Control

@onready var shooter: Node2D = $Shooters/Shooter :
	set(value):
		if shooter:
			shooter.selected = false
		shooter = value
		if shooter:
			shooter.selected = true
		selected_shooter.emit(shooter)

signal selected_shooter(node: Node2D)

@export var ShooterArea: Node2D

func _ready() -> void:
	self.shooter = shooter

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("action_delete"):
		shooter.queue_free()
		self.shooter = null
	if event.is_action_pressed("action_duplicate"):
		if shooter == null:
			return
		var dup = shooter.duplicate()
		shooter.selected = false
		shooter.object_settings = shooter.object_settings.duplicate()
		ShooterArea.add_child(dup)
		self.shooter = dup
		
