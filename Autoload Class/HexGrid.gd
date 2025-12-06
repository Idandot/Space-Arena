class_name HexGrid
extends Node2D

#pointy_top hexes

var _hex: PackedScene

var _grid_radius: int
var _grid: Dictionary[Vector2i, Hex]


func create_grid(radius: int):
	if _hex == null:
		push_error("grid cannot be created without Hex scene")
		return
	
	_grid_radius = radius
	
	var needed_hexes = AxialUtilities.hexes_in_radius(Vector2i.ZERO, radius)
	for hex_position in needed_hexes:
		var newHex = _hex.instantiate()
		_grid[hex_position] = newHex
		add_child(newHex)
		newHex.setup(hex_position)

func get_grid() -> Dictionary:
	return _grid

func get_hex_at(axial: Vector2i) -> Hex:
	return _grid[axial]

func get_grid_array() -> Array[Vector2i]:
	var hexes_array: Array[Vector2i] = []
	for hex_pos in _grid.keys():
		hexes_array.append(hex_pos)
	return hexes_array

func get_grid_world_size() -> Rect2:
	return AxialUtilities.find_rect(get_grid_array())

func get_grid_radius() -> int:
	return _grid_radius

func set_hex_scene(hex: PackedScene):
	_hex = hex

func highlight(hexes: Array[Vector2i],color:= Color.WHITE,force_initial_alpha := false, reset := true) -> void:
	if reset:
		reset_highlight()
	
	if !force_initial_alpha:
		color.a = 0.5
	
	for hex_position in hexes:
		if !_grid.has(hex_position):
			continue
		_grid[hex_position].fill_color = color

func reset_highlight() -> void:
	for hex: Hex in _grid.values():
			hex.fill_color = Color.TRANSPARENT
