extends Node2D

# Сделать генерализацию спавна
# Пофиксить сторону применения урона при столкновении
# Позволить игроку брать много разных пушек из списка доступных


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
	"ship_init": true
}

var player_ship: Node2D
var enemy_ship: Node2D

@export var starting_config = [
	[
		{
			"control": "bot", 
			"spawnpointOf": Vector2i(0,0), 
			"initial_facing": "rightdown",
			"max_acceleration": 3,
			"color": Color.BLUE
		},
		{
			"control": "bot", 
			"spawnpointOf": Vector2i(0,1), 
			"initial_facing": "rightdown",
			"max_acceleration": 3,
			"color": Color.CADET_BLUE
		}
	],
	[
		{
			"control": "bot", 
			"spawnpointOf": Vector2i(21,16),
			"initial_facing": "leftup",
			"max_acceleration": 3,
			"color": Color.RED
		},
		{
			"control": "bot", 
			"spawnpointOf": Vector2i(21,15), 
			"initial_facing": "leftup",
			"max_acceleration": 3,
			"color": Color.REBECCA_PURPLE
		}
	]
]


func _on_hex_grid_grid_created():
	var team_id = 0
	var ship_id = 0
	
	for team_data in starting_config:
		for teammate in team_data:
			var scene: PackedScene = null
			if teammate.control == "bot":
				scene = enemy_ship_scene
			else:
				scene = player_ship_scene
			
			var ship = scene.instantiate()
			ships.add_child(ship)
			ship.team_id = team_id
			ship.ship_id = ship_id
			ship.call_deferred("init_from_data", teammate)
			ShipsManager.register(ship)
			ship_id += 1
		team_id += 1
	
	print("ships spawned: ", ShipsManager.ships.size())
	turn_manager.start_game()




















