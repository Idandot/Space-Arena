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
	#берем позицию в аксиальных
	var new_pos_ax = ship.Position
	#Переводим в offset
	var new_pos_of = axial_to_offset(new_pos_ax.x, new_pos_ax.y)
	#Применяем ограничения
	new_pos_of.x = clamp(new_pos_of.x, 0, gridSizeOX - 1)
	new_pos_of.y = clamp(new_pos_of.y, 0, gridSizeOY - 1)
	#Переводим обратно в аксиальные
	new_pos_ax = offset_to_axial(new_pos_of.x, new_pos_of.y)
	ship.Position = new_pos_ax
	#Переводим в мировые координаты
	var world_pos = axial_to_world(new_pos_ax.x, new_pos_ax.y)
	ship.position = world_pos
