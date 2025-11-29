extends Node
class_name ShipMediator

@export var modules: Array[Module]

signal movement_ended(to: Vector2i)
func call_movement_ended(to: Vector2i):
	movement_ended.emit(to)

func collect_actions() -> Array[Action]:
	var actions: Array[Action] = []
	for module in modules:
		actions.append_array(module.get_available_actions())
	return actions

signal movement_animation_finished()
func call_movement_animation_finished():
	movement_animation_finished.emit()
