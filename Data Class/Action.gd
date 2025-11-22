extends RefCounted
class_name Action

var action_name: String
var callback: Callable
var input_action: String

func _init(_action_name: String, _callback: Callable, _input: String = "") -> void:
	action_name = _action_name
	callback = _callback
	if _input == "":
		_input = action_name
	input_action = _input
