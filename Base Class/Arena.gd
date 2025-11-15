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
	for actor_config in game_config.actors_data:
		var actor = actor_config.scene.instantiate()
		if !actor is Actor:
			push_warning("Only Actors can be used in Arena")
			continue
		add_child(actor)
		actor.setup(actor_config)
		actors.append(actor)
	
	#Можно начинать игру
	_turn_manager.start_game(actors)
