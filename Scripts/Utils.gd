extends Node

class_name SpaceArenaUtilities

const HEX_SIDE_SIZE = 20
const GRID_OFFSET_WX = 50
const GRID_OFFSET_WY = 50

const DIRECTION = [
	{"name":"up","index":0,"angle":-90,"vector":Vector2i(0,-1)},
	{"name":"rightup","index":1,"angle":-30,"vector":Vector2i(1,0)},
	{"name":"rightdown","index":2,"angle":30,"vector":Vector2i(1,1)},
	{"name":"down","index":3,"angle":90,"vector":Vector2i(0,1)},
	{"name":"leftdown","index":4,"angle":150,"vector":Vector2i(-1,0)},
	{"name":"leftup","index":5,"angle":-150,"vector":Vector2i(-1,-1)},
]

static func convert_direction(value, initial_type, target_type):
	if initial_type == "index":
		value = (value+6) % 6
	
	#ищем прямые совпадения
	for entry in DIRECTION:
		if value == entry[initial_type]:
			return entry[target_type]
	print("ERROR: Hadn't found ", value, " in the dictionary with initial type ", initial_type)
	return null

static func offset_to_world(offset_vector: Vector2i) -> Vector2:
	var ox = offset_vector.x
	var oy = offset_vector.y
	var x = GRID_OFFSET_WX + HEX_SIDE_SIZE * 1.5 * ox
	var y = GRID_OFFSET_WY + HEX_SIDE_SIZE * sqrt(3) * oy
	
	if ox % 2 == 1:
		y += HEX_SIDE_SIZE * sqrt(3) / 2
	return Vector2(x, y)

static func world_to_axial(world_vector: Vector2) -> Vector2i:
	var x = world_vector.x
	var y = world_vector.y
	var q = round((x - GRID_OFFSET_WX) / 1.5 / HEX_SIDE_SIZE)
	var r = round((y - GRID_OFFSET_WY) / sqrt(3) / HEX_SIDE_SIZE) + floor((q+1) / 2)
	return Vector2i(q, r)

static func offset_to_axial(offset_vector: Vector2i) -> Vector2i:
	var ox = offset_vector.x
	var oy = offset_vector.y
	var q = ox
	var r = oy + floor((ox + 1) / 2.0)
	return Vector2i(q, r)

static func axial_to_offset(axial_vector: Vector2i) -> Vector2i:
	var q = axial_vector.x
	var r = axial_vector.y
	var ox = q
	var oy = r - int(floor((ox + 1)/2.0))
	return Vector2i(ox, oy)

static func axial_to_offset_alt(axial_vector: Vector2i) -> Vector2i:
	var q = axial_vector.x
	var r = axial_vector.y
	var ox = q
	var oy = r + floor((q - (q & 1)) / 2.0)
	return Vector2i(ox, oy)

static func axial_to_world(axial_vector: Vector2i, relative:= false) -> Vector2:
	var q = axial_vector.x
	var r = axial_vector.y
	var x =  HEX_SIDE_SIZE * 1.5 * q
	var y = HEX_SIDE_SIZE * sqrt(3) * (r - q/2.0)
	if !relative:
		x += GRID_OFFSET_WX
		y += GRID_OFFSET_WY
	return Vector2(x, y)

static func axial_distance(axial_vector: Vector2i) -> int:
	var q = axial_vector.x
	var r = axial_vector.y
	var z = -q+r
	return int((abs(q) + abs(r) + abs(z))/2.0)

static func chance(positive: float,negative: float):
	return positive / (negative + positive + 10**(-10))

static func angle_difference(angle1: float, angle2: float) -> float:
	var diff = fmod(angle2 - angle1, 360.0)
	diff = angle_normalize(diff)
	return abs(diff)

static func angle_normalize(angle: float) -> float:
	if angle > 180:
		angle -= 360
	elif angle < -180:
		angle += 360
	return angle












