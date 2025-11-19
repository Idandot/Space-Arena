extends Node
class_name ShipMediator

signal movement_ended(to: Vector2i)

func call_movement_ended(to: Vector2i):
	movement_ended.emit(to)
