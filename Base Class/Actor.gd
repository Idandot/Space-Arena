extends Node
class_name Actor

#добавить больше сигналов по необходимости
signal setup_started(config: ActorConfig)
signal turn_ended(actor: Actor)
signal turn_started(actor: Actor)
signal killed(actor: Actor)

var _initiative: int = 0
var _is_alive: bool = true
var _state = ActorStates.IDLE

enum ActorStates {MOVEMENT, ANIMATION, IDLE}

func setup(config: ActorConfig) -> void:
	if not config:
		push_error("no config, setup aborted")
		return
	
	_is_alive = true
	
	setup_started.emit(config)
	_initiative = config.get_meta("initiative", 0)

func take_turn() -> void:
	_state = ActorStates.MOVEMENT
	if !_is_alive:
		return
	
	emit_signal("turn_started", self)


func end_turn() -> void:
	_state = ActorStates.IDLE
	emit_signal("turn_ended", self)

func get_initiative() -> int:
	return _initiative

func is_alive() -> bool:
	return _is_alive

func kill() -> void:
	_state = ActorStates.IDLE
	_is_alive = false
	killed.emit(self)

func set_state(state: ActorStates):
	_state = state

func get_state():
	return _state
