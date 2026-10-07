class_name HexGrid
extends Node2D

#pointy_top hexes

var _hex: PackedScene

var _grid_radius: int
var _grid: Dictionary[Vector2i, Hex]

enum highlight_layers {CURRENT_WEAPON, INSPECTED_WEAPON}

#Dictionary[StringName, Variant]
var _highlight_layers: Dictionary[highlight_layers, Dictionary]

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

func highlight_layer(
	layer: highlight_layers,
	hexes: Array[Vector2i],
	color: Color,
	force_initial_alpha := false,
	reset_other:= false) -> void:
	if reset_other:
		_highlight_layers.clear()
	
	if !force_initial_alpha:
		color.a = 0.5
	
	_highlight_layers[layer] = {"hexes": hexes, "color": color}
	_rebuild_visuals()

func clear_layer(layer) -> void:
	_highlight_layers.erase(layer)
	_rebuild_visuals()

func clear_all_layers() -> void:
	_highlight_layers.clear()
	_rebuild_visuals()

func _rebuild_visuals() -> void:
	for hex: Hex in _grid.values():
		hex.fill_color = Color.TRANSPARENT
	
	for layer_data in _highlight_layers.values():
		var hexes: Array[Vector2i] = layer_data["hexes"]
		var color: Color = layer_data["color"]
		for hex_position in hexes:
			if !_grid.has(hex_position):
				continue
			_grid[hex_position].fill_color = color
	return
