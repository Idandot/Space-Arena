extends Node2D

@export var ship_mediator: ShipMediator
@export var hex_rigidbody: HexRigidbody
@export var start_texture: TMTexture
@export var animation_duration = 1

@onready var texture := start_texture.duplicate(true)
@onready var parent: Node2D = self.get_parent()
var tween: Tween

func _ready():
	if parent.has_signal("turn_started"):
		parent.connect("turn_started", _queue_redraw)
	if parent.has_signal("turn_ended"):
		parent.connect("turn_ended", _reset_position)
	if parent.has_signal("setup_started"):
		parent.connect("setup_started", _setup)
	if parent.has_signal("facing_changed"):
		parent.connect("facing_changed", _rotate)
	ship_mediator.movement_ended.connect(_movement_animation)
	if hex_rigidbody != null:
		hex_rigidbody.facing_changed.connect(_rotate)

func _draw():
	if texture == null:
		print("no assigned texture")
		return
	
	var closed_points = texture.points.duplicate()
	if closed_points[0] != closed_points[closed_points.size()-1]:
		closed_points.append(closed_points[0])
	draw_polyline(closed_points, texture.line_color, texture.line_width)
	if texture.fill:
		draw_colored_polygon(texture.points, texture.fill_color)

func _queue_redraw(_actor: Actor) -> void:
	position = Vector2i.ZERO
	queue_redraw()

func _reset_position(_actor: Actor) -> void:
	position = Vector2i.ZERO

func _setup(config: ActorConfig):
	if texture == null:
		return
	texture.fill_color = config.color
	queue_redraw()

func _rotate(facing: HexOrientation):
	rotation = -deg_to_rad(facing.get_current_angle())
	queue_redraw()

func _movement_animation(to_ax: Vector2i):
	var to_w = AxialUtilities.axial_to_world(to_ax)
	
	var duration = animation_duration
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(self, "position", to_w, duration)
	
	await tween.finished
	
	position = Vector2.ZERO
	parent.end_turn()
