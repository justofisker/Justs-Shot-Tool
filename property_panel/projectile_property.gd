extends VBoxContainer

signal value_set(value)

var projectile := XMLObjects.Projectile.new() :
	set(value):
		projectile = value
		value_set.emit(value)

var value :
	set(value):
		projectile = value
	get():
		return projectile
