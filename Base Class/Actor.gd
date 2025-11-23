extends Node
class_name Actor

#добавить больше сигналов по необходимости
signal setup_started(config: ActorConfig)
signal turn_ended(actor: Actor)
signal turn_started(actor: Actor)
signal killed(actor: Actor)

var _display_name: String = ""
var _initiative: int = 0
var _is_alive: bool = true

var state: Enums.actor_states = Enums.actor_states.IDLE:
	set(value):
		state = value
		print(_display_name, "'s state changed to ", state)
	get:
		return state

func setup(config: ActorConfig) -> void:
	if not config:
		push_error("no config, setup aborted")
		return
	
	_is_alive = true
	
	setup_started.emit(config)
	_initiative = config.get_meta("initiative", 0)
	_display_name = config.get("display_name")

func take_turn() -> void:
	state = Enums.actor_states.ACTIVE
	if !_is_alive:
		return
	
	emit_signal("turn_started", self)


func end_turn() -> void:
	state = Enums.actor_states.IDLE
	await get_tree().process_frame
	emit_signal("turn_ended", self)

func get_initiative() -> int:
	return _initiative

func is_alive() -> bool:
	return _is_alive

func kill() -> void:
	state = Enums.actor_states.IDLE
	_is_alive = false
	killed.emit(self)
