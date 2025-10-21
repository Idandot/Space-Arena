extends Node2D

@export var hex_color = Color(1,0.5,1)
@export var Hex: PackedScene
@export var gridSizeOX = 10
@export var gridSizeOY = 6

var currentHex
var grid = Array()
var newShip: Node2D

@onready var Root = get_parent()

signal gridCreated

func get_hex_corner(center: Vector2, i: int):
	var angle = deg_to_rad(i*60)
	var x = center.x + Root.hexSideSizeW * cos(angle)
	var y = center.y + Root.hexSideSizeW * sin(angle)
	return Vector2(x, y)

func _ready():
	grid.resize(gridSizeOX)
	for ox in range(gridSizeOX):
		grid[ox] = Array()
		grid[ox].resize(gridSizeOY)
		for oy in range(gridSizeOY):
			var newHex = Hex.instantiate()
			add_child(newHex)
			newHex.setup(Root.hexSideSizeW, Root.offset_to_world(Vector2i(ox, oy)))
			newHex.connect("clicked", on_hex_clicked)
			grid[ox][oy]=(newHex)
	emit_signal("gridCreated")

func on_hex_clicked(hex):
	for x in grid:
		for y in grid[x]:
			y.change_color(Color(1,1,1))
			y.z_index = 0
	hex.change_color(Color(0,1,1))
	hex.z_index = 5
	currentHex = hex

func get_hex(axial: Vector2i):
	var offset: Vector2i = Root.axial_to_offset(axial)
	var oX = offset.x
	var oY = offset.y
	if oX < grid.size():
		if oY < grid[oX].size():
			return grid[oX][oY]
	return null

func get_hexes_in_range(ax_center: Vector2i, range: int):
	var result = Array()
	
	for aX in range(-range, range + 1):
		#прямые -x-range и -x+range это ограничители вдоль оси z
		for aY in range(max(-range,-aX-range), min(range, -aX + range) +1):
			var aZ = -aX - aY
			if abs(aZ) <= range:
				var hex_pos = ax_center + Vector2i(aX, aY)
				var hex = get_hex(hex_pos)
				if hex:
					var distance = Root.axial_distance(hex_pos - ax_center)
					result.append({"hex": hex, "distance": distance, "axial_position": hex_pos})
	return result
















