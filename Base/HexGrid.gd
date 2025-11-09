class_name HexGrid
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

func get_grid() -> Dictionary:
	return grid

func get_hex_at(axial: Vector2i) -> Hex:
	return grid[axial]

func get_grid_array() -> Array[Vector2i]:
	var hexes_array: Array[Vector2i]
	for hex_pos in grid.keys():
		hexes_array.append(hex_pos)
	return hexes_array

func get_grid_world_size() -> Rect2:
	return AxialUtilities.find_rect(get_grid_array())










