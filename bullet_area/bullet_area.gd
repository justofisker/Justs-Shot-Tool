extends Control

@onready var shooter: Node2D = $Shooter

var attack :
	set(value):
		shooter.attack = value

var projectile :
	set(value):
		shooter.projectile = value
