extends Node
class_name Actor

#добавить больше сигналов по необходимости
signal setup_started(config: ActorConfig)
signal turn_ended(actor: Actor)
signal turn_started(actor: Actor)


@export var modules: Array[PackedScene] = []

var _initiative = 0
var _is_alive = true

func setup(config: ActorConfig):
	setup_started.emit(config)

func take_turn():
	emit_signal("turn_started", self)
	end_turn()

func start_movement_phase():
	pass

func end_turn():
	emit_signal("turn_ended", self)

func get_initiative():
	return _initiative

func is_alive():
	return _is_alive












