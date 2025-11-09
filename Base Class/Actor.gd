extends Node
class_name Actor

signal turn_ended(actor)

var _initiative = 0

func take_turn():
	end_turn()

func end_turn():
	emit_signal("turn_ended", self)

func get_initiative():
	return _initiative
