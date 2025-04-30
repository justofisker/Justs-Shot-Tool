extends Control

@onready var shooter: Node2D = $Shooter :
	set(value):
		shooter = value
		selected_shooter.emit(shooter)

signal selected_shooter(node: Node2D)

func _ready() -> void:
	self.shooter = shooter
