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
	
	run_all_tests()

func _find_spawn_points() -> Array[Vector2i]:
	var spawn_points: Array[Vector2i] = []
	for direction in AxialUtilities.get_directions_table():
		var new_spawn_point = direction["vector"] * arena_radius
		spawn_points.append(new_spawn_point)
	
	return spawn_points

func run_all_tests():
	var tests = [
		Vector2i(3, 0),    # Простой
		Vector2i(2, -2),   # Диагональ  
		Vector2i(3, -1),   # Комбинация
		Vector2i(1, -1),   # Точно по диагонали
		Vector2i(0, 0),    # Ноль
		Vector2i(1, -2),   # Выбор соседа
		Vector2i(1, 1),    # Сложный случай
		Vector2i(5, -3),   # Большой
		Vector2i(2, -1)    # Еще комбинация
	]

	for i in range(tests.size()):
		print("Test ", i + 1, ": ", tests[i])
		var result = AxialUtilities.decompose_vector(tests[i])
		print("Result: ", result)
		var sum = Vector2i.ZERO
		for vec in result:
			sum += vec
		print("Sum: ", sum, " | Match: ", sum == tests[i])
		print("---")
