@abstract
extends Node
class_name Module

#FLUFF
var module_name: String:
	get():
		return "%s %d" % [module_name, instance_index]
var module_acronym: String = "M1"
var description: String


var actor_mediator: ActorMediator
var tags: Array[Enums.module_tags]
var _active: bool = true
var grid_position: Vector2i
var ship_layout: ShipLayout
var parent: Actor
var _integrity: Integrity
var instance_index: int

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
	_integrity.current -= amount
	GameEvents.log_request.emit("%s had taken %d damage in %s. Integrity: %s/%s" % [
		parent.display_name, amount, module_name, _integrity.current, _integrity.maximum
	])
	if _integrity.current <= 0:
		print(module_name, " module destroyed")
		_active = false
		destruction_action()
		return abs(_integrity.current)
	return 0

func get_integrity() -> Integrity:
	return _integrity
