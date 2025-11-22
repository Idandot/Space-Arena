extends Controller
class_name PlayerController

##Вызывается в начале хода
func _take_control(_actor: Actor):
	var actions = ship_mediator.collect_actions()
	for action in actions:
		_actions[action.action_name] = action

func get_available_actions() -> Array[Action]:
	return [
		Action.new("end_phase", _end_phase, "end_phase")
	]

func _process(_delta: float) -> void:
	if parent._state == parent.ActorStates.MOVEMENT:
		_handle_input()

func _handle_input():
	for action in _actions:
		if Input.is_action_just_pressed(_actions[action].input_action):
			_actions[action].callback.call()

func _end_phase():
	ship_mediator.call_planning_completed()
