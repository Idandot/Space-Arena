extends Node2D

#pointy_top hexes

@export var Hex: PackedScene

var grid_radius: int
var grid: Dictionary #key: Vector2i -> value: Hex object

func create_grid(radius: int):
	grid_radius = radius
	
	var needed_hexes = AxialUtilities.axial_in_radius(Vector2i.ZERO, radius)
	for hex_position in needed_hexes:
		var newHex = Hex.instantiate()
		grid[hex_position] = newHex
		add_child(newHex)
		newHex.setup(hex_position)
