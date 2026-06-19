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
var description: String = "":
	set(value):
		description = value
	get:
		return description
var is_active: bool:
	set(value):
		is_active = value
	get:
		return is_active

var _initiative: int = 0
var _round_initiative: float
var _is_alive: bool = true

func setup(config: ActorConfig) -> void:
	if not config:
		push_error("no config, setup aborted")
		return
	
	_is_alive = true
	
	setup_started.emit(config)
	_initiative = config.get("initiative")
	_round_initiative = _initiative
	display_name = config.get("display_name")
	description = config.get("description")
	
	TurnManager.round_started.connect(_calculate_round_initiative)

func take_turn(phase: Enums.game_states) -> void:
	if !_is_alive:
		return
	is_active = true
	
	emit_signal("turn_started", self, phase)

func end_turn() -> void:
	is_active = false
	
	await get_tree().process_frame
	emit_signal("turn_ended", self)

func get_initiative() -> float:
	return _round_initiative

func is_alive() -> bool:
	return _is_alive

func kill() -> void:
	is_active = false
	_is_alive = false
	killed.emit(self)

func _calculate_round_initiative(_new_round: int) -> void:
	_round_initiative = _initiative + randf()
	GameEvents.log_request.emit("%s's this round initiative is %.2f" % [display_name, _round_initiative])
