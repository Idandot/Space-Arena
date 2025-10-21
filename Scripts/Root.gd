extends Node2D

@export var acceleration_label: Label
@export var turn_label: Label
@export var ships: Node2D
@export var hex_grid: Node2D
@export var turn_manager: Node2D
@export var hexSideSizeW = 50
@export var gridOffsetWX = 50
@export var gridOffsetWY = 50
@export var player_ship_scene: PackedScene
@export var enemy_ship_scene: PackedScene

var player_ship: Node2D
var enemy_ship: Node2D
var ships_array: Array

func offset_to_world(offset_vector: Vector2i) -> Vector2:
	var ox = offset_vector.x
	var oy = offset_vector.y
	var x = gridOffsetWX + hexSideSizeW * 1.5 * ox
	var y = gridOffsetWY + hexSideSizeW * sqrt(3) * oy
	
	if ox % 2 == 1:
		y += hexSideSizeW * sqrt(3) / 2
	return Vector2(x, y)

func world_to_axial(world_vector: Vector2) -> Vector2i:
	var x = world_vector.x
	var y = world_vector.y
	var q = round((x - gridOffsetWX) / 1.5 / hexSideSizeW)
	var r = round((y - gridOffsetWY) / sqrt(3) / hexSideSizeW) + floor((q+1) / 2)
	return Vector2i(q, r)

func offset_to_axial(offset_vector: Vector2i) -> Vector2i:
	var ox = offset_vector.x
	var oy = offset_vector.y
	var q = ox
	var r = oy + floor((ox + 1) / 2.0)
	return Vector2i(q, r)

func axial_to_offset(axial_vector: Vector2i) -> Vector2i:
	var q = axial_vector.x
	var r = axial_vector.y
	var ox = q
	var oy = r - int(floor((ox + 1)/2.0))
	return Vector2i(ox, oy)

func axial_to_offset_alt(axial_vector: Vector2i) -> Vector2i:
	var q = axial_vector.x
	var r = axial_vector.y
	var ox = q
	var oy = r + (q - (q & 1)) / 2
	return Vector2i(ox, oy)

func axial_to_world(axial_vector: Vector2i, relative: bool) -> Vector2:
	var q = axial_vector.x
	var r = axial_vector.y
	var x =  hexSideSizeW * 1.5 * q
	var y = hexSideSizeW * sqrt(3) * (r - q/2.0)
	if !relative:
		x += gridOffsetWX
		y += gridOffsetWY
	return Vector2(x, y)

func axial_distance(axial_vector: Vector2i) -> int:
	var q = axial_vector.x
	var r = axial_vector.y
	var z = -q-r
	return int((abs(q) + abs(r) + abs(z))/2.0)

func chance(positive: float,negative: float):
	return positive / (negative + positive + 10**(-10))

func angle_difference(angle1: float, angle2: float) -> float:
	var diff = fmod(angle1 - angle2 + 180, 360) - 180
	return diff
	

func _on_hex_grid_grid_created():
	#Создаем корабль игрока
	player_ship = player_ship_scene.instantiate()
	ships.add_child(player_ship)
	player_ship.position = axial_to_world(Vector2i(0,0), false)
	player_ship.axial_position = Vector2i(0,0)
	player_ship.hex_grid = hex_grid
	player_ship.self_id = 0
	ships_array.append(player_ship)
	#Создаем корабль противника
	enemy_ship = enemy_ship_scene.instantiate()
	ships.add_child(enemy_ship)
	enemy_ship.position = axial_to_world(offset_to_axial(Vector2i(hex_grid.gridSizeOX-1, hex_grid.gridSizeOY-1)), false)
	enemy_ship.axial_position = offset_to_axial(Vector2i(hex_grid.gridSizeOX-1, hex_grid.gridSizeOY-1))
	enemy_ship.hex_grid = hex_grid
	enemy_ship.self_id = 1
	enemy_ship.player = player_ship
	ships_array.append(enemy_ship)
	
	turn_manager.start_game(ships_array)
	test_real_conversion()

func test_real_conversion():
	# Возьми реальные offset координаты из твоей сетки
	var test_offsets = [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1,1), Vector2i(2,0)]
	
	for offset in test_offsets:
		var axial = offset_to_axial(offset)
		var back_to_offset = axial_to_offset(axial)
		print("Offset:", offset, " -> Axial:", axial, " -> Back:", back_to_offset, " Match:", offset == back_to_offset)











