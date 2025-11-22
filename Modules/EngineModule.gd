extends Module
class_name EngineModule

@export var hex_rigidbody: HexRigidbody
@export var engine_config: EngineConfig

var _thrust: int

const ENGINE_IMPULSE_ID = "engine_acceleration"

#ПУБЛИЧНЫЕ МЕТОДЫ

##Возвращает доступные действия модуля
func get_available_actions() -> Array[Action]:
	if !_active:
		return []
	return [
		Action.new("accelerate", _accelerate),
		Action.new("turn_right", _turn_right),
		Action.new("turn_left", _turn_left),
		Action.new("brake", _brake),
	]

#ДЕЙСТВИЯ МОДУЛЯ

##Действие ускоряющее корабль в направлении носа
func _accelerate():
	if !_active:
		return
	if !_try_spend_thrust(engine_config.acceleration_cost):
		return
	_apply_impulse(engine_config.acceleration_power)

##Действие поворачивающее корабль по часовой
func _turn_right():
	if !_active:
		return
	if !_try_spend_thrust(engine_config.turn_cost):
		return
	var facing: HexOrientation = hex_rigidbody.get_facing()
	facing.turn_right()
	_apply_facing(facing)

##Действие поворачивающее корабль против часовой
func _turn_left():
	if !_active:
		return
	if !_try_spend_thrust(engine_config.turn_cost):
		return
	var facing: HexOrientation = hex_rigidbody.get_facing()
	facing.turn_left()
	_apply_facing(facing)

##Действие ускоряющее корабль в противоположном направлении от носа
func _brake():
	if !_active:
		return
	if !_try_spend_thrust(engine_config.brake_cost):
		return
	_apply_impulse(engine_config.brake_power)

#ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ

func _ready():
	if !engine_config or !hex_rigidbody:
		_active = false
	parent.turn_started.connect(_on_turn_started)

func _on_turn_started(_actor: Actor):
	if !_active:
		return
	_thrust = min(_thrust + engine_config.thrust_regeneration, engine_config.max_thrust)

func _try_spend_thrust(amount: int) -> bool:
	if !_active:
		return false
	if amount > _thrust:
		print("Not enough thrust to make action")
		return false
	_thrust -= amount
	return true

func _apply_impulse(power: int):
	if !_active:
		return
	var facing: HexOrientation = hex_rigidbody.get_facing()
	hex_rigidbody.add_impulse(ENGINE_IMPULSE_ID, power*facing.get_current_vector())

func _apply_facing(facing: HexOrientation):
	if !_active:
		return
	hex_rigidbody.set_facing(facing.get_current_name())
