extends Node
class_name ShipMediator

signal movement_ended(to: Vector2i, coeff: int)

func call_movement_ended(to: Vector2i, coeff:=0):
	movement_ended.emit(to, coeff)
