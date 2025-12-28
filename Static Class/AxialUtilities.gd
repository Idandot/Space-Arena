extends Node
class_name AxialUtilities

const HEX_SIDE := 64
const SQRT3 := sqrt(3)
const HEX_HEIGHT := HEX_SIDE * 2
const HEX_WIDTH := HEX_SIDE * SQRT3

const DIRECTIONS: Array[Dictionary]= [
	{"name": "R", "index": 0, "vector": Vector2i(1,0)},
	{"name": "RUU", "index": 1, "vector": Vector2i(1,-1)},
	{"name": "LUU", "index": 2, "vector": Vector2i(0,-1)},
	{"name": "L", "index": 3, "vector": Vector2i(-1,0)},
	{"name": "LDD", "index": 4, "vector": Vector2i(-1,1)},
	{"name": "RDD", "index": 5, "vector": Vector2i(0,1)},
]

static func get_direction_index(value) -> int:
	if typeof(value) == TYPE_INT:
		return (value+6) % 6
	
	var directions = get_directions_table()
	var key = "name" if typeof(value) == TYPE_STRING else "vector"
	
	for direction in directions:
		if direction[key] == value:
			return direction["index"]
	
	push_warning("value not found: ", value)
	return 0

static func get_directions_table() -> Array[Dictionary]:
	return DIRECTIONS

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

static func angle_between(v1a: Vector2i, v2a: Vector2i) -> float:
	var v1w: Vector2 = axial_to_world(v1a)
	var v2w: Vector2 = axial_to_world(v2a)
	var angle_rad = v2w.angle() - v1w.angle()
	
	return rad_to_deg(angle_rad)

static func hexes_in_radius(center: Vector2i, radius: int, inner_radius: int = 0) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	
	for q in range(-radius, +radius +1):
		for r in range(max(-radius, -q-radius), min(radius, -q+radius)+1):
			if distance(Vector2i(q, r)) < inner_radius:
				continue
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

static func decompose_vector(vector: Vector2i) -> Array[Vector2i]:
	#Ищем основное направление по максимальному скалярному произведению
	var main_directions = get_directions_table()
	var best_dot = -INF
	var main_dir_vector: Vector2i
	var main_dir_index: int
	for i in range(6):
		var dir_vector = main_directions[i]["vector"]
		var dir_vectorW = axial_to_world(dir_vector)
		var vectorW = axial_to_world(vector)
		var dot = vectorW.x * dir_vectorW.x + vectorW.y * dir_vectorW.y
		if dot > best_dot:
			best_dot = dot
			main_dir_vector = dir_vector
			main_dir_index = i
	
	#Ищем побочное направление по максимальному скалярному произведению
	var diagonal_directions = get_directions_table()
	best_dot = -INF
	var sec_dir_vector: Vector2i
	for i in range(6):
		if i == main_dir_index:
			continue
		var dir_vector = diagonal_directions[i]["vector"]
		var dir_vectorW = axial_to_world(dir_vector)
		var vectorW = axial_to_world(vector)
		var dot = vectorW.x * dir_vectorW.x + vectorW.y * dir_vectorW.y
		if dot > best_dot:
			best_dot = dot
			sec_dir_vector = dir_vector
	
	#Теперь нужно определить правильное разложение
	var final_solution = solve_by_Cramer(main_dir_vector, sec_dir_vector, vector)
	
	#Создаем итоговое разложение
	var result_decomposition: Array[Vector2i] = []
	for i in range(final_solution.x):
		result_decomposition.append(main_dir_vector)
	for i in range(final_solution.y):
		result_decomposition.append(sec_dir_vector)
	
	#Проверка полного совпадения
	var composed_vector:= Vector2i.ZERO
	for v in result_decomposition:
		composed_vector += v
	if composed_vector != vector:
		push_error("FUCK, IT DIDN'T WORK")
	
	return result_decomposition

static func solve_by_Cramer(colA: Vector2, colB: Vector2, C: Vector2) -> Vector2:
	var det = colA.x * colB.y - colA.y * colB.x
	if det == 0:
		print("linearly dependent")
		return Vector2.ZERO
	var A = (C.x * colB.y - C.y * colB.x)/det
	var B = (colA.x * C.y - colA.y * C.x)/det
	return Vector2(A, B)

static func hexes_in_sector(origin: Vector2i, 
					facing: Vector2i,
					arc_degrees: float = 120, 
					min_range: int = 0, 
					max_range: int = 50):
	
	var _hexes_in_sector: Array[Vector2i] = []
	
	var _half_arc = arc_degrees / 2
	var _hexes_in_radius = hexes_in_radius(origin, min_range, max_range)
	
	for hex_pos in _hexes_in_radius:
		var angle_degrees = abs(angle_between(hex_pos - origin, facing))
		if angle_degrees <= _half_arc + 0.001:
			_hexes_in_sector.append(hex_pos)
	
	return _hexes_in_sector
