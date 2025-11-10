extends Node
class_name Actor

#добавить больше сигналов по необходимости
signal turn_ended(actor)

var _initiative = 0
var _is_alive = true

@onready var controller: Controller = $Controller

func take_turn():
	end_turn()

func start_movement_phase():
	pass

func end_turn():
	emit_signal("turn_ended", self)

func get_initiative():
	return _initiative

func is_alive():
	return _is_alive

















