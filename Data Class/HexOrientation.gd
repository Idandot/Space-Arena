extends Node
class_name HexOrientation

var _index := 0
var _name := "right"
var _vector := Vector2i(1,0)
var _angle := 0

const DIRECTION = [
	{"name": "right", "index": 0, "vector": Vector2i(1,0)},
	{"name": "rightup", "index": 1, "vector": Vector2i(1,-1)},
	{"name": "leftup", "index": 2, "vector": Vector2i(0,-1)},
	{"name": "left", "index": 3, "vector": Vector2i(-1,0)},
	{"name": "leftdown", "index": 4, "vector": Vector2i(-1,1)},
	{"name": "rightdown", "index": 5, "vector": Vector2i(0,1)},
]

func _get_direction_index(value) -> int:
	var value_type = typeof(value)
	var key: String
	match value_type:
		TYPE_INT:
			value = (value % 6 + 6) % 6
			return value
		TYPE_STRING:
			key = "name"
		TYPE_VECTOR2I:
			key = "vector"
		_:
			push_warning("value: ", value, " isn't matching type")
			return 0
	
	for direction in DIRECTION:
		if direction[key] == value:
			return direction["index"]
	push_warning("value: ", value, " not found in table")
	return 0

func _get_angle(value) -> int:
	var index = _get_direction_index(value)
	var angle = index * 60
	if angle > 180:
		return angle - 360
	else:
		return angle

func set_direction(value):
	_index = _get_direction_index(value)
	_name = DIRECTION[_index]["name"]
	_vector = DIRECTION[_index]["vector"]
	_angle = _get_angle(_index)

func get_direction() -> Dictionary:
	return DIRECTION[_index]

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










