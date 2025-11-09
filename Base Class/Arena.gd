extends Node2D

#Занимается начальным сетапом арены, а за ходами следить будет TurnManager

@export var arena_radius = 10

#Арена без HexGrid это как секс без девушки
@onready var _hex_grid: HexGrid = $HexGrid
#Наблюдатель обязателен
@onready var _arena_camera: ArenaCamera = $ArenaCamera
#Организатор ходов
@onready var _turn_manager: TurnManager = $TurnManager
#Вынести в ресурс в будущем!
@export var actors_ref: Array[PackedScene] = [
	
]

func _ready():
	#нужно создать арену и дождаться ее полного создания!
	await _hex_grid.create_grid(arena_radius)
	#чтобы все было видно, подстраиваем камеру
	_arena_camera.zoom_to_fit(_hex_grid.get_grid_world_size())
	
	#Инициализируем всех актеров
	var actors: Array[Actor] = []
	for actor_ref in actors_ref:
		var actor = actor_ref.instantiate()
		add_child(actor)
		actors.append(actor)
	
	#Можно начинать игру
	_turn_manager.start_game(actors)

