extends Node2D

@export var start_texture: TMTexture

@onready var texture := start_texture.duplicate(true)
@onready var parent: Node2D = self.get_parent()

func _ready():
	if parent.has_signal("turn_started"):
		parent.connect("turn_started", _queue_redraw)
	if parent.has_signal("setup_started"):
		parent.connect("setup_started", _setup)

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
	queue_redraw()

func _setup(config: ActorConfig):
	if texture == null:
		return
	texture.fill_color = config.color
	queue_redraw()
