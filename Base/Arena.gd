extends Node2D

#Занимается начальным сетапом арены, а за ходами следить будет TurnManager

@export var arena_radius = 10

#Арена без HexGrid это как секс без девушки
@onready var hex_grid: HexGrid = $HexGrid
#Наблюдатель обязателен
@onready var arena_camera: ArenaCamera = $Camera2D

func _ready():
	#нужно создать арену и дождаться ее полного создания!
	await hex_grid.create_grid(arena_radius)
	#чтобы все было видно, подстраиваем камеру
	arena_camera.zoom_to_fit(hex_grid.get_grid_world_size())

