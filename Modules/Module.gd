@abstract
extends Node
class_name Module

var actor_mediator: ActorMediator
var tags: Array[Enums.module_tags]
var _max_module_integrity: int = 5
var _active: bool = true
var module_name: String
var grid_position: Vector2i
var ship_layout: ShipLayout
var parent: Actor

@onready var _module_integrity: int = _max_module_integrity

@abstract
func get_available_actions() -> Array[Action]

#переопределяется у детей
func setup(_config: Resource) -> void:
	pass

func take_damage(amount: int) -> int:
	_module_integrity -= amount
	if _module_integrity <= 0:
		print(module_name, " module destroyed")
		_active = false
		return abs(_module_integrity)
	return 0
