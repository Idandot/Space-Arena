extends Node2D

var points := []
@onready var colPoly = $Area2D/CollisionPolygon2D
@onready var poly = $Area2D/Polygon2D
var color: Color = Color.WHITE
var coordinates: Vector2i

func setup(pos: Vector2i):
	coordinates = pos
	var side_size = AxialUtilities.HEX_SIDE
	for i in range(7):
		var angle = deg_to_rad(60*i + 30)
		points.append(Vector2(cos(angle), sin(angle))*side_size)
	colPoly.polygon = points
	
	self.position = AxialUtilities.axial_to_world(coordinates)
	queue_redraw()

func _draw():
	if len(points) != 0:
		draw_polyline(points, color)
