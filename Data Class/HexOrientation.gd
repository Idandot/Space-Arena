extends Node
class_name HexOrientation

var _index := 0
var _name := "right"
var _vector := Vector2i(1,0)
var _angle := 0

func _get_angle(value) -> int:
	var index = AxialUtilities.get_direction_index(value)
	var angle = index * 60
	if angle > 180:
		return angle - 360
	else:
		return angle

func set_direction(value):
	_index = AxialUtilities.get_direction_index(value)
	_name = AxialUtilities.get_directions_table()[_index]["name"]
	_vector = AxialUtilities.get_directions_table()[_index]["vector"]
	_angle = _get_angle(_index)

func get_direction() -> Dictionary:
	return AxialUtilities.get_directions_table()[_index]

func get_current_index() -> int:
	return _index

func get_current_name() -> String:
	return _name

func get_current_vector() -> Vector2i:
	return _vector

func get_current_angle() -> int:
	return _angle

func turn_right():
	set_direction(_index - 1)

func turn_left():
	set_direction(_index + 1)

func turn_by_index(index):
	set_direction(_index + index)
