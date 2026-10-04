extends Node2D
class_name TargetManager

@export var marker_radius := AxialUtilities.HEX_SIDE * 0.7
@export var marker_color := Color.RED
@export var marker_line_coeff := 0.2
@export var line_width := 2
var _ax_marker_pos: Vector2i
var _is_marker_visible: bool = false

func _ready() -> void:
	GameEvents.target_change.connect(change_target)
	GameEvents.toggle_target.connect(toggle_marker)

func _draw() -> void:
	if !_is_marker_visible:
		return
	
	var w_marker_pos: Vector2 = AxialUtilities.axial_to_world(_ax_marker_pos)
	
	draw_arc(w_marker_pos, marker_radius, 0, TAU, 32, marker_color, line_width)
	
	var line_length: float = marker_radius * marker_line_coeff
	
	for i in range(0, 4):
		var angle = i * PI/2 + PI/4
		var direction: Vector2 = Vector2(1, 0).rotated(angle)
		draw_line(
			w_marker_pos + direction * (marker_radius - line_length),
			w_marker_pos + direction * (marker_radius + line_length),
			marker_color, line_width
			)

func change_target(actor: Actor) -> void:
	var to_ax: Vector2i = Vector2i.ZERO
	var hex_rigidbody: HexRigidbody = actor.get_node_or_null(^"HexRigidbody")
	if hex_rigidbody != null:
		to_ax = hex_rigidbody.axial_position
	_ax_marker_pos = to_ax
	queue_redraw()

func toggle_marker(visibility: bool = false) -> void:
	_is_marker_visible = visibility
	queue_redraw()
