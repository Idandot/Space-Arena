extends Node
class_name AxialUtilities

const HEX_SIDE := 64
const SQRT3 := sqrt(3)

static func axial_to_world(axial: Vector2i) -> Vector2:
	var q = axial.x
	var r = axial.y
	
	var x = SQRT3 * q + SQRT3 /2 * r
	var y = 3.0/2 * r
	
	x *= HEX_SIDE
	y *= HEX_SIDE
	
	return Vector2(x, y)

static func world_to_axial(world: Vector2) -> Vector2i:
	
	push_warning("func axial_to_world isn't yet written")
	return Vector2i(0,0)

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
	
	
	push_warning("func round_axial isn't yet written")
	return Vector2i(0,0)

static func axial_in_radius(center: Vector2i, radius: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	
	for q in range(-radius, +radius +1):
		for r in range(max(-radius, -q-radius), min(radius, -q+radius)+1):
			result.append(Vector2i(q, r) + center)
	
	return result


static func find_rect(hexes: Array[Vector2i]) -> Rect2:
	if hexes.is_empty():
		return Rect2()
	
	var world_points: PackedVector2Array
	
	for hex in hexes:
		var world_pos = axial_to_world(hex)
	
	push_warning("func find_rect isn't yet written")
	return Rect2()
