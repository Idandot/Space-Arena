extends Area2D


@export var window_reference: PackedScene
@export var ship_contents: PackedScene

var window: InspectionWindow
@onready var actor: Actor = self.get_parent().get_parent()

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			open_window()
	return

func open_window():
	if !window_reference:
		push_warning("No reference!")
		return
	
	window = window_reference.instantiate()
	window.setup(actor, actor.display_name, ship_contents)
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	get_tree().root.add_child(canvas)
	canvas.add_child(window)
