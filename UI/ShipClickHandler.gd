extends Area2D
class_name ShipClickHandler

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
	
	var inspector_parent = _find_inspector_parent()
	
	inspector_parent.add_child(window)
	
	var viewport_size:= get_viewport().get_visible_rect().size
	window.position = Vector2(
		(viewport_size.x - window.size.x) / 2,
		(viewport_size.y - window.size.y) / 2
	)

func _find_inspector_parent() -> Control:
	var arena = get_tree().get_first_node_in_group("Arena")
	if arena:
		return arena.get_node_or_null("CanvasLayer/InspectorParent")
	
	return get_tree().root.get_node_or_null("Arena/CanvasLayer/InspectorParent")
