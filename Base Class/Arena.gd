extends Node2D

#Занимается начальным сетапом арены, а за ходами следить будет TurnManager

@export var arena_radius = 10
@export var hex_scene: PackedScene

#TODO: сделать менее жесткие связи между Arena и ее детьми

#Наблюдатель обязателен
@onready var _arena_camera: ArenaCamera = $ArenaCamera
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
	TurnManager.start_game(actors, game_config)
	
	init_test_cases()


func _find_spawn_points() -> Array[Vector2i]:
	var spawn_points: Array[Vector2i] = []
	for direction in AxialUtilities.get_directions_table():
		var new_spawn_point = direction["vector"] * arena_radius
		spawn_points.append(new_spawn_point)
	
	return spawn_points

var test_cases = []

func init_test_cases():
	# Убираем предыдущие случаи
	test_cases.clear()
	
	# Базовые направления (шесть основных в гексагональной сетке)
	var directions = [
		Vector2i(1, 0),   # Вправо
		Vector2i(1, -1),  # Вправо-вверх
		Vector2i(0, -1),  # Вверх-влево
		Vector2i(-1, 0),  # Влево
		Vector2i(-1, 1),  # Влево-вниз
		Vector2i(0, 1),   # Вниз-вправо
	]

	# Разные углы секторов
	var angles = [60, 90, 120, 180, 240, 360]

	# Разные радиусы
	var radius_ranges = [[0, 2], [0, 4], [2, 4], [1, 3]]

	# Разные цвета для наглядности
	var colors = [Color.RED, Color.GREEN, Color.BLUE, Color.YELLOW, Color.PURPLE, Color.CYAN]

	# Генерируем тестовые случаи
	var case_index = 0
	
	for dir_index in range(directions.size()):
		for angle in angles:
			for radius_range in radius_ranges:
				# Добавляем тестовый случай
				test_cases.append({
					"name": "Case " + str(case_index),
					"origin": Vector2i.ZERO,
					"facing": directions[dir_index],
					"color": colors[case_index % colors.size()],
					"arc_degrees": angle,
					"min_radius": radius_range[0],
					"max_radius": radius_range[1]
				})
				case_index += 1
				# Ограничим количество тестовых случаев, чтобы не слишком много
				
				if case_index >= 24:  # 24 различных комбинации
					print("1")
					break
			if case_index >= 24:  # 24 различных комбинации
				print("2")
				break
		if case_index >= 24:  # 24 различных комбинации
			print("3")
			break
	
	print("4")
	for test_case in test_cases:
		run_test_case(test_case)
		await get_tree().create_timer(2).timeout
	HexGridClass.reset_highlight()

func run_test_case(test_case):
	# Выводим информацию о текущем тесте в консоль
	print("Тест: ", test_case["name"])
	print("  Направление: ", test_case["facing"])
	print("  Угол: ", test_case["arc_degrees"], "градусов")
	print("  Радиусы: от ", test_case["min_radius"], " до ", test_case["max_radius"])
	print("  Цвет: ", test_case["color"])

	# Запускаем подсветку
	HighlightManager.highlight_sector(
		test_case["origin"],
		test_case["facing"],
		test_case["color"],
		test_case["arc_degrees"],
		test_case["min_radius"],
		test_case["max_radius"]
	)
