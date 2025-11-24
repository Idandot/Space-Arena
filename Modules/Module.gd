@abstract
extends Node
class_name Module

@export var ship_mediator: ShipMediator
@export var tags: Array[Enums.module_tags]:
	get():
		return tags


var _max_module_integrity: int = 100
@onready var _module_integrity: int = _max_module_integrity
var _active: bool = true
var _module_name: String

@onready var parent: Actor = ship_mediator.get_parent()

@abstract
func get_available_actions() -> Array[Action]

func take_damage(amount: int) -> int:
	_module_integrity -= amount
	if _module_integrity <= 0:
		print(_module_name, " module destroyed")
		_active = false
		return abs(_module_integrity)
	return 0
