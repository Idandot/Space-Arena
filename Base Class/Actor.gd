extends Node
class_name Actor

#добавить больше сигналов по необходимости
signal setup_started(config: ActorConfig)
signal turn_ended(actor: Actor)
signal turn_started(actor: Actor, phase: Enums.game_states)
signal killed(actor: Actor)

var display_name: String = "":
	set(value):
		display_name = value
	get:
		return display_name
var _initiative: int = 0
var _is_alive: bool = true

var is_active: bool:
	set(value):
		is_active = value
	get:
		return is_active

func setup(config: ActorConfig) -> void:
	if not config:
		push_error("no config, setup aborted")
		return
	
	_is_alive = true
	
	setup_started.emit(config)
	_initiative = config.get("initiative")
	display_name = config.get("display_name")

func take_turn(phase: Enums.game_states) -> void:
	if !_is_alive:
		return
	is_active = true
	
	emit_signal("turn_started", self, phase)

func end_turn() -> void:
	is_active = false
	
	await get_tree().process_frame
	emit_signal("turn_ended", self)

func get_initiative() -> int:
	return _initiative

func is_alive() -> bool:
	return _is_alive

func kill() -> void:
	is_active = false
	_is_alive = false
	killed.emit(self)
