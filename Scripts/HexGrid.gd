extends Node2D

@export var hex_color = Color(1,0.5,1)
@export var Hex: PackedScene
@export var gridSizeOX = 10
@export var gridSizeOY = 6

var currentHex
var grid = []
var newShip: Node2D

@onready var Root = get_parent()

signal gridCreated

func get_hex_corner(center: Vector2, i: int):
	var angle = deg_to_rad(i*60)
	var x = center.x + Root.hexSideSizeW * cos(angle)
	var y = center.y + Root.hexSideSizeW * sin(angle)
	return Vector2(x, y)

func _ready():
	for ox in range(gridSizeOX):
		for oy in range(gridSizeOY):
			var newHex = Hex.instantiate()
			add_child(newHex)
			newHex.setup(Root.hexSideSizeW, Root.offset_to_world(Vector2i(ox, oy)))
			newHex.connect("clicked", on_hex_clicked)
			grid.append(newHex)
	emit_signal("gridCreated")

func on_hex_clicked(hex):
	for h in grid:
		h.change_color(Color(1,1,1))
		h.z_index = 0
	hex.change_color(Color(0,1,1))
	hex.z_index = 5
	currentHex = hex






















