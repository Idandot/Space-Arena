extends Node2D

# W - world coordisnates
# O - offset coordinates
# A - axial coordinates
# C - cubic coordinates

@export var hexSideSizeW = 50
@export var gridOffsetWX = 50
@export var gridOffsetWY = 50
@export var gridSizeOX = 7
@export var gridSizeOY = 7
@export var hexColor = Color(1,0.5,1)
@export var Hex: PackedScene
@export var Ship: PackedScene
var currentHex
var grid = []
var newShip: Node2D


func offset_to_world(ox: int, oy: int):
	var x = gridOffsetWX + hexSideSizeW * 1.5 * ox
	var y = gridOffsetWY + hexSideSizeW * sqrt(3) * oy
	
	if ox % 2 == 1:
		y += hexSideSizeW * sqrt(3) / 2
	return Vector2(x, y)

func world_to_axial(x, y):
	var q = round((x - gridOffsetWX) / 1.5 / hexSideSizeW)
	var r = round((y - gridOffsetWY) / sqrt(3) / hexSideSizeW) + floor((q+1) / 2)
	return Vector2i(q, r)

func offset_to_axial(ox: int, oy: int) -> Vector2i:
	var q = ox
	var r = oy + floor((ox + 1) / 2.0)
	print(Vector2i(q, r))
	return Vector2i(q, r)

func axial_to_offset(q: int, r: int):
	var ox = q
	var oy = r - int(floor((ox + 1)/2.0))
	return Vector2i(ox, oy)

func axial_to_world(q: int, r: int):
	var x = gridOffsetWX + hexSideSizeW * 1.5 * q
	var y = gridOffsetWY + hexSideSizeW * sqrt(3) * (r - q/2.0)
	return Vector2(x, y)

func get_hex_corner(center: Vector2, i: int):
	var angle = deg_to_rad(i*60)
	var x = center.x + hexSideSizeW * cos(angle)
	var y = center.y + hexSideSizeW * sin(angle)
	return Vector2(x, y)

func _ready():
	for ox in range(gridSizeOX):
		for oy in range(gridSizeOY):
			var newHex = Hex.instantiate()
			add_child(newHex)
			newHex.setup(hexSideSizeW, offset_to_world(ox, oy))
			newHex.connect("clicked", on_hex_clicked)
			grid.append(newHex)
	print(grid)
	newShip = Ship.instantiate()
	add_child(newShip)
	newShip.setup()
	newShip.position = axial_to_world(0,0)
	newShip.connect("end_movement", Callable(self, "update_ship_position"))

func on_hex_clicked(hex):
	for h in grid:
		h.change_color(Color(1,1,1))
		h.z_index = 0
	hex.change_color(Color(0,1,1))
	hex.z_index = 5
	currentHex = hex

func update_ship_position(ship):
	var new_vel_ax = ship.NewVelocity
	var new_pos_ax = ship.Position
	var path = decompose_vector(new_pos_ax, new_pos_ax + new_vel_ax)
	for step in path:
		var next_pos_ax = new_pos_ax + step
		var next_pos_of = axial_to_offset(next_pos_ax.x, next_pos_ax.y)
		if next_pos_of.x != clamp(next_pos_of.x, 0, gridSizeOX - 1) \
		or next_pos_of.y != clamp(next_pos_of.y, 0, gridSizeOY - 1):
			print("pushed in the wall")
			break
		else:
			new_pos_ax = next_pos_ax
	ship.Position = new_pos_ax
	var world_pos = axial_to_world(new_pos_ax.x, new_pos_ax.y)
	ship.position = world_pos

func decompose_vector(start_pos: Vector2i, end_pos: Vector2i) -> Array:
	var change_pos = end_pos - start_pos
	print(change_pos)
	var path = []
	while change_pos != Vector2i.ZERO:
		var h = change_pos.x
		var k = change_pos.y
		var l = h+k
		if abs(h) >= abs(k) and abs(h) >= abs(l):
			var step = Vector2i(sign(h), 0)
			change_pos -= step
			path.append(step)
		elif abs(k) >= abs(l) and abs(k) >= abs(h):
			var step = Vector2i(0, sign(k))
			change_pos -= step
			path.append(Vector2i(step))
		else:
			var step = Vector2i(sign(l), sign(l))
			change_pos -= step
			path.append(step)
	print(path)
	return path

 






















