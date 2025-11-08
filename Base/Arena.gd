extends Node2D

#Занимается начальным сетапом арены, ходы будет выполнять TurnManager!

@export var arena_radius = 5

#ВНИМАНИЕ: требует модуль HexGrid для работы!
@onready var hex_grid: Node2D = $HexGrid

func _ready():
	hex_grid.create_grid(arena_radius)
