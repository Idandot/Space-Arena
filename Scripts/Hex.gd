extends Node2D

var points = []
@onready var colPoly = $Area2D/CollisionPolygon2D
@onready var poly = $Area2D/Polygon2D
var color: Color = Color(1,1,1)
var self_offset_coordinates: Vector2i
var self_axial_coordinates: Vector2i

signal clicked(hex: Node)

func setup(hexSideSize: int, pos: Vector2):
	for i in range(7):
		var angle = deg_to_rad(60*i)
		points.append(Vector2(cos(angle), sin(angle))*hexSideSize)
	colPoly.polygon = points
	self.position = pos
	queue_redraw()

func _draw():
	if len(points) != 0:
		draw_polyline(points, color)

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("clicked", self)

func change_color(new_color: Color):
	color = new_color
	queue_redraw()

func set_coordinates(axial: Vector2i, offset: Vector2i):
	self_offset_coordinates = offset
	self_axial_coordinates = axial
