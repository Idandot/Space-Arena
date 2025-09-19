extends Node2D

# W - world coordisnates
# O - offset coordinates
# A - axial coordinates

@export var hexSideSizeW = 50
@export var gridOffsetWX = 50
@export var gridOffsetWY = 50
@export var gridSizeOX = 10
@export var gridSizeOY = 6
@export var hexColor = Color(1,0.5,1)
@export var Hex: PackedScene
@export var Ship: PackedScene
@export var AccelerationText: Control

var currentHex
var grid = []
var newShip: Node2D

#UTILITY METHODS

func offset_to_world(offsetV: Vector2i) -> Vector2:
	var ox = offsetV.x
	var oy = offsetV.y
	var x = gridOffsetWX + hexSideSizeW * 1.5 * ox
	var y = gridOffsetWY + hexSideSizeW * sqrt(3) * oy
	
	if ox % 2 == 1:
		y += hexSideSizeW * sqrt(3) / 2
	return Vector2(x, y)

func world_to_axial(worldV: Vector2) -> Vector2i:
	var x = worldV.x
	var y = worldV.y
	var q = round((x - gridOffsetWX) / 1.5 / hexSideSizeW)
	var r = round((y - gridOffsetWY) / sqrt(3) / hexSideSizeW) + floor((q+1) / 2)
	return Vector2i(q, r)

func offset_to_axial(offsetV: Vector2i) -> Vector2i:
	var ox = offsetV.x
	var oy = offsetV.y
	var q = ox
	var r = oy + floor((ox + 1) / 2.0)
	print(Vector2i(q, r))
	return Vector2i(q, r)

func axial_to_offset(axialV: Vector2i) -> Vector2i:
	var q = axialV.x
	var r = axialV.y
	var ox = q
	var oy = r - int(floor((ox + 1)/2.0))
	return Vector2i(ox, oy)

func axial_to_world(axialV: Vector2i, relative: bool) -> Vector2:
	var q = axialV.x
	var r = axialV.y
	var x =  hexSideSizeW * 1.5 * q
	var y = hexSideSizeW * sqrt(3) * (r - q/2.0)
	if !relative:
		x += gridOffsetWX
		y += gridOffsetWY
	return Vector2(x, y)

func get_hex_corner(center: Vector2, i: int):
	var angle = deg_to_rad(i*60)
	var x = center.x + hexSideSizeW * cos(angle)
	var y = center.y + hexSideSizeW * sin(angle)
	return Vector2(x, y)

#GAMEPLAY METHODS

func _ready():
	for ox in range(gridSizeOX):
		for oy in range(gridSizeOY):
			var newHex = Hex.instantiate()
			add_child(newHex)
			newHex.setup(hexSideSizeW, offset_to_world(Vector2i(ox, oy)))
			newHex.connect("clicked", on_hex_clicked)
			grid.append(newHex)
	newShip = Ship.instantiate()
	add_child(newShip)
	newShip.position = axial_to_world(Vector2i.ZERO, false)
	print(AccelerationText.text)

func on_hex_clicked(hex):
	for h in grid:
		h.change_color(Color(1,1,1))
		h.z_index = 0
	hex.change_color(Color(0,1,1))
	hex.z_index = 5
	currentHex = hex






















