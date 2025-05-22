extends VBoxContainer

signal value_set(value)

var attack := XMLObjects.Subattack.new() :
	set(value):
		attack = value
		value_set.emit(value)

var value :
	set(value):
		attack = value
	get():
		return attack
