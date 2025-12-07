extends Control
class_name inspection_window

signal window_closed(window_instance)
signal window_minimized(window_instance, is_minimized)

@export var title: String = "Untitled":
	set(value):
		title = value
		if is_instance_valid(title_label):
			title_label.text = title

@export var title_label: Label
@export var close_button: Button
@export var minimize_button: Button
@export var margin_container: MarginContainer
@export var content_area: Node

var _inspected_object: Object = null

func _ready() -> void:
	title = title
	
	close_button.pressed.connect(_on_close_button_pressed)
	minimize_button.pressed.connect(_on_minimizer_button_pressed)
	_update_minimize_state(false)









func _on_close_button_pressed():
	return

func _on_minimizer_button_pressed():
	return

func _update_minimize_state(_ool: bool):
	return
