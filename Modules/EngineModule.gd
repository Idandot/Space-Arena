extends Module
class_name EngineModule

var hex_rigidbody: HexRigidbody
@export var engine_config: EngineConfig

var _thrust: int
var _initial_thrust: int

const ENGINE_IMPULSE_ID = "engine_acceleration"

#ПУБЛИЧНЫЕ МЕТОДЫ

func setup(config: Resource) -> void:
	engine_config = config
	hex_rigidbody = parent.find_child("HexRigidbody")
	
	if !engine_config or !hex_rigidbody:
		_active = false
	parent.turn_started.connect(_on_turn_started)
	module_name = engine_config.config_name
	module_acronym = engine_config.config_acronym
	description = engine_config.config_description
	_integrity = Integrity.new(engine_config.max_engine_integrity, engine_config.max_engine_integrity)
	print(_integrity.get_text())

##Возвращает доступные действия модуля
func get_available_actions() -> Array[Action]:
	if !_active:
		return []
	return [
		Action.new("accelerate", _accelerate, Enums.game_states.MOVEMENT),
		Action.new("turn_right", _turn_right, Enums.game_states.MOVEMENT),
		Action.new("turn_left", _turn_left, Enums.game_states.MOVEMENT),
		Action.new("brake", _brake, Enums.game_states.MOVEMENT),
		Action.new("reset_move", _reset_move, Enums.game_states.MOVEMENT)
	]

func get_stats_text() -> String:
	var stats_text := ""
	for property in engine_config.get_property_list():
		if !property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			continue
		if property.type != TYPE_INT:
			continue
		
		stats_text += "%s: %s\n" % [property["name"], engine_config.get(property["name"])]
	return stats_text

#ДЕЙСТВИЯ МОДУЛЯ

##Действие ускоряющее корабль в направлении носа
func _accelerate():
	if !_active:
		GameEvents.log_request.emit("Engine is not configured or severely damaged, cannot perform action")
		return
	if !_try_spend_thrust(engine_config.acceleration_cost):
		return
	_apply_impulse(engine_config.acceleration_power)

##Действие поворачивающее корабль по часовой
func _turn_right():
	if !_active:
		GameEvents.log_request.emit("Engine is not configured or severely damaged, cannot perform action")
		return
	if !_try_spend_thrust(engine_config.turn_cost):
		return
	var facing: HexOrientation = hex_rigidbody.facing
	facing.turn_right()
	_apply_facing(facing)

##Действие поворачивающее корабль против часовой
func _turn_left():
	if !_active:
		GameEvents.log_request.emit("Engine is not configured or severely damaged, cannot perform action")
		return
	if !_try_spend_thrust(engine_config.turn_cost):
		return
	var facing: HexOrientation = hex_rigidbody.facing
	facing.turn_left()
	_apply_facing(facing)

##Действие ускоряющее корабль в противоположном направлении от носа
func _brake():
	if !_active:
		GameEvents.log_request.emit("Engine is not configured or severely damaged, cannot perform action")
		return
	if !_try_spend_thrust(engine_config.brake_cost):
		return
	_apply_impulse(engine_config.brake_power)

func _reset_move():
	if !_active:
		GameEvents.log_request.emit("Engine is not configured or severely damaged, cannot perform action")
		return
	hex_rigidbody.restore_initial_state()
	_thrust = _initial_thrust
	GameEvents.thrust_changed.emit(parent, _thrust, engine_config.max_thrust)
	GameEvents.log_request.emit("move reset")

#ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ

func _on_turn_started(_actor: Actor, _phase: Enums.game_states):
	if !_active:
		GameEvents.log_request.emit("Engine is not configured or severely damaged, cannot regain thrust")
		return
	_thrust = min(_thrust + engine_config.thrust_regeneration, engine_config.max_thrust)
	_initial_thrust = _thrust
	GameEvents.thrust_changed.emit(parent, _thrust, engine_config.max_thrust)

func _try_spend_thrust(amount: int) -> bool:
	if !_active:
		GameEvents.log_request.emit("Engine is not configured or severely damaged, cannot spend thrust")
		return false
	if amount > _thrust:
		GameEvents.log_request.emit("Not enough thrust to make action")
		return false
	_thrust -= amount
	GameEvents.thrust_changed.emit(parent, _thrust, engine_config.max_thrust)
	return true

func _apply_impulse(power: int):
	if !_active:
		return
	var facing: HexOrientation = hex_rigidbody.facing
	hex_rigidbody.add_impulse(ENGINE_IMPULSE_ID, power*facing.get_current_vector())

func _apply_facing(facing: HexOrientation):
	if !_active:
		return
	hex_rigidbody.facing = facing.get_current_name()
