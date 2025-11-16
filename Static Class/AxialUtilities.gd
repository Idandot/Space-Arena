extends Node
class_name AxialUtilities

const HEX_SIDE := 64
const SQRT3 := sqrt(3)
const HEX_HEIGHT := HEX_SIDE * 2
const HEX_WIDTH := HEX_SIDE * SQRT3

const MAIN_DIRECTIONS = [
	{"name": "right", "index": 0, "vector": Vector2i(1,0)},
	{"name": "rightup", "index": 1, "vector": Vector2i(1,-1)},
	{"name": "leftup", "index": 2, "vector": Vector2i(0,-1)},
	{"name": "left", "index": 3, "vector": Vector2i(-1,0)},
	{"name": "leftdown", "index": 4, "vector": Vector2i(-1,1)},
	{"name": "rightdown", "index": 5, "vector": Vector2i(0,1)},
]

static func get_direction_index(value) -> int:
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
	
	for direction in AxialUtilities.MAIN_DIRECTIONS:
		if direction[key] == value:
			return direction["index"]
	push_warning("value: ", value, " not found in table")
	return 0

static func axial_to_world(axial: Vector2i) -> Vector2:
	var q = axial.x
	var r = axial.y
	
	var x = SQRT3 * q + SQRT3 /2 * r
	var y = 3.0/2 * r
	
	x *= HEX_SIDE
	y *= HEX_SIDE
	
	return Vector2(x, y)

static func world_to_axial(world: Vector2) -> Vector2i:
	var x = world.x
	var y = world.y
	
	x /= HEX_SIDE
	y /= HEX_SIDE
	
	var fq = SQRT3/3 * x - 1.0/3 * y
	var fr = 2.0/3 * y
	
	return round_axial(Vector2(fq,fr))

static func round_axial(axial_frac: Vector2) -> Vector2i:
	var fq = axial_frac.x
	var fr = axial_frac.y
	var fs = -fq-fr
	
	var q = round(fq)
	var r = round(fr)
	var s = round(fs)
	
	var dq = abs(q-fq)
	var dr = abs(r-fr)
	var ds = abs(s-fs)
	
	if dq > dr and dq > ds:
		q = -r-s
	elif dr > ds:
		r = -q-s
	else:
		s = -q-r
	
	return Vector2i(q,r)

static func hexes_in_radius(center: Vector2i, radius: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	
	for q in range(-radius, +radius +1):
		for r in range(max(-radius, -q-radius), min(radius, -q+radius)+1):
			result.append(Vector2i(q, r) + center)
	
	return result

static func distance(vector: Vector2i) -> int:
	var q = vector.x
	var r = vector.y
	var s = -q-r
	return max(abs(q), abs(r), abs(s))

static func axial_clamp(vector: Vector2i, radius: int) -> Vector2i:
	var dist = distance(vector)
	if dist <= radius:
		return vector
	
	var length = float(dist)
	var scale = float(radius)/length
	var fracv2 = vector*scale
	
	return round_axial(fracv2)

static func find_rect(hexes: Array[Vector2i]) -> Rect2:
	if hexes.is_empty():
		return Rect2()
	
	var world_points: PackedVector2Array = []
	
	for hex in hexes:
		var world_pos = axial_to_world(hex)
		world_points.append(world_pos)
	
	var min_point = world_points[0]
	var max_point = world_points[0]
	
	for point in world_points:
		min_point.x = min(min_point.x, point.x)
		min_point.y = min(min_point.y, point.y)
		max_point.x = max(max_point.x, point.x)
		max_point.y = max(max_point.y, point.y)
	
	max_point.x += HEX_WIDTH /2.0
	min_point.x -= HEX_WIDTH /2.0
	max_point.y += HEX_HEIGHT /2.0
	min_point.y -= HEX_HEIGHT /2.0
	
	var rect_position = min_point
	var rect_size = max_point - min_point 
	
	return Rect2(rect_position, rect_size)
