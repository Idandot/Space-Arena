@abstract
extends Node
class_name Module

#FLUFF
var module_name: String
var module_acronym: String = "M1"
var description: String


var actor_mediator: ActorMediator
var tags: Array[Enums.module_tags]
var max_module_integrity: int = 5
var _active: bool = true
var grid_position: Vector2i
var ship_layout: ShipLayout
var parent: Actor

@onready var module_integrity: int = max_module_integrity

@abstract
func get_available_actions() -> Array[Action]

#переопределяется у детей
func setup(_config: Resource) -> void:
	pass

func get_stats_text() -> String:
	return ""

func destruction_action() -> void:
	return

func take_damage(amount: int) -> int:
	module_integrity -= amount
	GameEvents.log_request.emit("%s had taken %d damage in %s. Integrity: %s/%s" % [
		parent.display_name, amount, module_name, module_integrity, max_module_integrity
	])
	if module_integrity <= 0:
		print(module_name, " module destroyed")
		_active = false
		destruction_action()
		return abs(module_integrity)
	return 0
