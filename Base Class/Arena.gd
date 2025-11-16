extends Node2D

#Занимается начальным сетапом арены, а за ходами следить будет TurnManager

@export var arena_radius = 10
@export var hex_scene: PackedScene

#TODO: сделать менее жесткие связи между Arena и ее детьми

#Наблюдатель обязателен
@onready var _arena_camera: ArenaCamera = $ArenaCamera
#Организатор ходов
@onready var _turn_manager: TurnManager = $TurnManager
@export var game_config: GameConfig


func _ready():
	#нужно создать арену и дождаться ее полного создания!
	HexGridClass.set_hex_scene(hex_scene)
	await HexGridClass.create_grid(arena_radius)
	#чтобы все было видно, подстраиваем камеру
	_arena_camera.zoom_to_fit(HexGridClass.get_grid_world_size())
	
	#Инициализируем всех актеров
	var actors: Array[Actor] = []
	var spawn_points = _find_spawn_points()
	var current_spawn_point = 0
	for actor_config in game_config.actors_data:
		actor_config = actor_config.duplicate_deep()
		var actor = actor_config.scene.instantiate() as Actor
		if !actor:
			push_warning("Only Actors can be used in Arena")
			continue
		if !actor_config.unique_spawnpoint:
			actor_config.spawn_point = spawn_points[current_spawn_point]
			current_spawn_point = (current_spawn_point + 1) % 6
		add_child(actor)
		actor.setup(actor_config)
		actors.append(actor)
	
	#Можно начинать игру
	_turn_manager.start_game(actors)

func _find_spawn_points() -> Array[Vector2i]:
	var spawn_points: Array[Vector2i] = []
	for direction in AxialUtilities.MAIN_DIRECTIONS:
		var new_spawn_point = direction["vector"] * arena_radius
		spawn_points.append(new_spawn_point)
	
	return spawn_points
