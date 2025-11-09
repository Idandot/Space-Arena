extends Node2D
class_name Hex

var _points := []
@onready var _colPoly = $Area2D/CollisionPolygon2D
var _color: Color = Color.WHITE
var _coordinates: Vector2i

func setup(pos: Vector2i):
	_coordinates = pos
	var side_size = AxialUtilities.HEX_SIDE
	for i in range(7):
		var angle = deg_to_rad(60*i + 30)
		_points.append(Vector2(cos(angle), sin(angle))*side_size)
	_colPoly.polygon = _points
	
	self.position = AxialUtilities.axial_to_world(_coordinates)
	queue_redraw()

func _draw():
	if len(_points) != 0:
		draw_polyline(_points, _color)
