extends Node2D

@export var acceleration_label: Label
@export var turn_label: Label
@export var ships: Node2D
@export var hex_grid: Node2D
@export var turn_manager: Node2D
@export var player_ship_scene: PackedScene
@export var enemy_ship_scene: PackedScene
@export var Utils = SpaceArenaUtilities

@export var debug_mode = {
	"ship_position": false,
	"ship_rotation": false,
}

var player_ship: Node2D
var enemy_ship: Node2D
var ships_array: Array
	

func _on_hex_grid_grid_created():
	#Создаем корабль игрока
	player_ship = player_ship_scene.instantiate()
	ships.add_child(player_ship)
	player_ship.position = Utils.axial_to_world(Vector2i(0,0), false)
	player_ship.axial_position = Vector2i(0,0)
	player_ship.hex_grid = hex_grid
	player_ship.self_id = 0
	ships_array.append(player_ship)
	#Создаем корабль противника
	enemy_ship = enemy_ship_scene.instantiate()
	ships.add_child(enemy_ship)
	enemy_ship.position = Utils.axial_to_world(Utils.offset_to_axial(Vector2i(hex_grid.gridSizeOX-1, hex_grid.gridSizeOY-1)), false)
	enemy_ship.axial_position = Utils.offset_to_axial(Vector2i(hex_grid.gridSizeOX-1, hex_grid.gridSizeOY-1))
	enemy_ship.hex_grid = hex_grid
	enemy_ship.self_id = 1
	enemy_ship.player = player_ship
	ships_array.append(enemy_ship)
	
	turn_manager.start_game(ships_array)



















