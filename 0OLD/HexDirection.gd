extends RefCounted
class_name HexDirection

var index: int
var name: String
var angle: int
var vector: Vector2i


const DIRECTION = [
	{"name":"up","index":0,"angle":-90,"vector":Vector2i(0,-1)},
	{"name":"rightup","index":1,"angle":-30,"vector":Vector2i(1,0)},
	{"name":"rightdown","index":2,"angle":30,"vector":Vector2i(1,1)},
	{"name":"down","index":3,"angle":90,"vector":Vector2i(0,1)},
	{"name":"leftdown","index":4,"angle":150,"vector":Vector2i(-1,0)},
	{"name":"leftup","index":5,"angle":-150,"vector":Vector2i(-1,-1)},
]

func _init(initial_direction):
	set_direction(initial_direction)

func get_table(value):
	var initial_type:=type_definer(value)
	
	if initial_type == "index":
		value = (value+6) % 6
	
	#ищем прямые совпадения
	for entry in DIRECTION:
		if value == entry[initial_type]:
			return entry
	push_error("Cannot find ", value, "of type ", initial_type)
	return DIRECTION[0]

func set_direction(value):
	var data = get_table(value)
	index = data.index
	name = data.name
	angle = data.angle
	vector = data.vector

func rotate_right():
	rotate_by_60_inc(1)

func rotate_left():
	rotate_by_60_inc(-1)

func rotate_by_60_inc(inc: int):
	index = (index + inc + 6) % 6
	set_direction(index)


func type_definer(value) -> String:
	#angle is not supported
	
	var value_type = typeof(value)
	
	if value_type == TYPE_STRING:
		return "name"
	elif value_type == TYPE_VECTOR2I:
		return "vector"
	else:
		return "index"

func get_index() -> int:
	return index

func get_name() -> String:
	return name

func get_vector() -> Vector2i:
	return vector

func get_angle() -> int:
	return angle










