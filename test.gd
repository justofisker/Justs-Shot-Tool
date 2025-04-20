extends Node

func _ready() -> void:
	var test = XMLObjects.Subattack.new()
	
	print(test.to_xml())
	var proj = XMLObjects.Projectile.new()
	proj.particle_trail = true
	proj.particle_trail_color = 0xfff
	print(proj.to_xml())
	var desc = XMLObjects.ProjectileDescription.new()
	print(desc.to_xml())
