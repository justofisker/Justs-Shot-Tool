extends HBoxContainer

@export var grabber_normal = preload("res://gui/slider_grabber.png")
@export var grabber_in_arena = preload("res://gui/SliderGrabber.svg")
@export var grabber_hover = preload("res://gui/SliderGrabberHover.svg")
@onready var slider: HSlider = $PanelContainer/HSlider

func _ready() -> void:
	mouse_entered.connect(_mouse_entered)
	mouse_entered.connect(_mouse_exited)

func _mouse_entered() -> void:
	slider.add_theme_icon_override("grabber", grabber_in_arena)
	slider.add_theme_icon_override("grabber_highlight", grabber_in_arena)

func _mouse_exited() -> void:
	slider.add_theme_icon_override("grabber", grabber_normal)
	slider.add_theme_icon_override("grabber_highlight", grabber_normal)
