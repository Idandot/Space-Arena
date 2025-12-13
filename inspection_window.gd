extends Control
class_name InspectionWindow

signal window_closed(window_instance)
signal window_is_minimized(window_instance, is_is_minimized)

@export var title: String = "Untitled":
	set(value):
		title = value
		if is_instance_valid(title_label):
			title_label.text = title

@export var title_label: Label
@export var close_button: Button
@export var minimize_button: Button
@export var body_panel: Panel
@export var container: Container

var window_content: Node

var _inspected_object: Object = null
var _is_minimized: bool = false

func _ready() -> void:
	title = title
	
	close_button.pressed.connect(_on_close_button_pressed)
	minimize_button.pressed.connect(_on_minimize_button_pressed)
	title_label.gui_input.connect(_on_title_label_gui_input)

func setup(object: Object, setup_title: String, content: PackedScene):
	title = setup_title
	_inspected_object = object
	window_content = content.instantiate()
	container.add_child(window_content)

func _on_close_button_pressed():
	queue_free()
	window_closed.emit(self)

func _on_minimize_button_pressed():
	_is_minimized = !_is_minimized
	body_panel.visible = !_is_minimized
	window_is_minimized.emit(self, _is_minimized)

var drag_offset = Vector2.ZERO

func _on_title_label_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				drag_offset = get_local_mouse_position()
			else:
				drag_offset = Vector2.ZERO
	if event is InputEventMouseMotion:
		if drag_offset != Vector2.ZERO:
			global_position = get_global_mouse_position() - drag_offset
			_clamp_to_screen()

func _clamp_to_screen():
	var viewport_size = get_viewport().get_visible_rect().size
	var window_size = size
	
	position.x = clamp(position.x, 0, viewport_size.x - window_size.x)
	position.y = clamp(position.y, 0, viewport_size.y - window_size.y)
