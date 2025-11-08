extends Node2D

var points = []
var points_selected = []
@onready var colPoly = $Area2D/CollisionPolygon2D
@onready var poly = $Area2D/Polygon2D
@onready var poly_selected = $Polygon2D
var color: Color = Color(1,1,1)
var self_offset_coordinates: Vector2i
var self_axial_coordinates: Vector2i
var selected_hex_side_size: int

func setup(hexSideSize: int, pos: Vector2):
	selected_hex_side_size = hexSideSize - 2
	for i in range(7):
		var angle = deg_to_rad(60*i)
		points.append(Vector2(cos(angle), sin(angle))*hexSideSize)
	colPoly.polygon = points
	self.position = pos
	for i in range(7):
		var angle = deg_to_rad(60*i)
		points_selected.append(Vector2(cos(angle), sin(angle))*selected_hex_side_size)
	poly_selected.polygon = points_selected
	poly_selected.hide()
	queue_redraw()

func _draw():
	if len(points) != 0:
		draw_polyline(points, color)

func change_color(new_color: Color, new_z_index: int):
	self.z_index = new_z_index
	color = new_color
	queue_redraw()

func selected(new_color: Color):
	poly_selected.show()
	poly_selected.color = new_color
	queue_redraw()

func deselected():
	poly_selected.hide()

func set_coordinates(axial: Vector2i, offset: Vector2i):
	self_offset_coordinates = offset
	self_axial_coordinates = axial
