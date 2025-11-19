extends Node2D
class_name HexRigidbody

@export var ship_mediator: ShipMediator

var _facing = HexOrientation.new()
#текущее положение обьекта на игровой сетке
var _axial_position = Vector2i.ZERO
#Текущая скорость тела, применяется в конце хода
var _velocity = Vector2i.ZERO
#Смещение тела с учетом скорости и обьектов на пути
var _displacement = Vector2i.ZERO
#Скорость с прошлого хода
var _previous_velocity = Vector2i.ZERO
#Одноразовые изменения скорости
var _impulse_dict: Dictionary[String, Vector2i] = {}
#Постоянные силы действующие на тело
var _force_dict: Dictionary[String, Vector2i] = {}


@onready var parent: Actor = self.get_parent()
@onready var event_bus: Node

signal facing_changed(facing: HexOrientation)
signal velocity_changed(velocity_data: Dictionary[String, Variant])

#ПУБЛИЧНЫЕ МЕТОДЫ

func get_velocity_data() -> Dictionary[String, Variant]:
	return {
		"previous_velocity": _previous_velocity,
		"impulse_dict": _impulse_dict.duplicate(),
		"force_dict": _force_dict.duplicate(),
		"result": _velocity,
	}

func add_force(force_name: String, value: Vector2i):
	_register_impact(_force_dict, force_name)
	_force_dict[force_name] += value
	velocity_changed.emit(get_velocity_data())

func add_impulse(impulse_name: String, value: Vector2i):
	_register_impact(_impulse_dict, impulse_name)
	_impulse_dict[impulse_name] += value
	velocity_changed.emit(get_velocity_data())

func set_axial_position(axial: Vector2i):
	_axial_position = axial
	parent.position = AxialUtilities.axial_to_world(_axial_position)

func get_axial_position() -> Vector2i:
	return _axial_position

func set_facing(value):
	_facing.set_direction(value)
	facing_changed.emit(_facing)

#ЛОКАЛЬНЫЕ МЕТОДЫ

func _ready() -> void:
	if parent.has_signal("turn_ended"):
		parent.turn_ended.connect(_on_turn_end)
	if parent.has_signal("setup_started"):
		parent.setup_started.connect(_on_setup)
	if parent.has_signal("turn_started"):
		parent.turn_started.connect(_on_turn_start)

##Фаза инициализации корабля
func _on_setup(_config: ActorConfig):
	set_axial_position(_config.spawn_point)
	
	#Временно для дебага!
	add_force("gravity", Vector2i(1, 0))
	add_impulse("throw", Vector2i(-6, 2))

##Фаза планирования движения
func _on_turn_start(_actor: Actor):
	_displacement = _calculate_displacement()
	_velocity = _calculate_velocity()
	velocity_changed.emit(get_velocity_data())
	
	#В будущем заменим на сигнал от контроллера
	await get_tree().create_timer(0.5).timeout
	_planning_completed()

##Фаза анимации перемещения, многие функции не работают правильно в эту фазу
func _planning_completed():
	_displacement = _calculate_displacement()
	_velocity = _calculate_velocity()
	_commit_velocity()
	parent.set_state(parent.ActorStates.ANIMATION)
	_start_movement_animation()

##Настоящий конец хода, фактическое перемещение
func _on_turn_end(_actor: Actor):
	_apply_velocity()
	velocity_changed.emit(get_velocity_data())

#ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ

func _calculate_velocity() -> Vector2i:
	var new_velocity = _previous_velocity
	for impulse in _impulse_dict.values():
		new_velocity += impulse
	for force in _force_dict.values():
		new_velocity += force
	return new_velocity

func _calculate_displacement() -> Vector2i:
	var th_velocity = _calculate_velocity()
	var path = AxialUtilities.decompose_vector(th_velocity)
	var displacement = Vector2i.ZERO
	for link in path:
		var predicted_position = _axial_position + displacement + link
		var clamped_position = AxialUtilities.axial_clamp(predicted_position, HexGridClass.get_grid_radius())
		if clamped_position != predicted_position:
			break
		displacement += link
	return displacement

func _commit_velocity():
	_previous_velocity = _velocity
	_impulse_dict.clear()

func _register_impact(dict: Dictionary[String, Vector2i], force_name: String):
	if !dict.has(force_name):
		dict[force_name] = Vector2i.ZERO

func _apply_velocity():
	set_axial_position(_axial_position + _displacement)

func _start_movement_animation():
	ship_mediator.call_movement_ended(_velocity)
