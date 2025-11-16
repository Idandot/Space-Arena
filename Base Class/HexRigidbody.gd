extends Node
class_name HexRigidbody

var _facing = HexOrientation.new()
#текущее положение обьекта на игровой сетке
var _axial_position = Vector2i.ZERO
#Текущая скорость тела, применяется в конце хода
var _velocity = Vector2i.ZERO
#Скорость с прошлого хода
var _previous_velocity = Vector2i.ZERO
#Одноразовые изменения скорости
var _impulse_dict: Dictionary[String, Vector2i] = {}
#Постоянные силы действующие на тело
var _force_dict: Dictionary[String, Vector2i] = {}

@onready var parent: Actor = self.get_parent()
@onready var event_bus: Node

signal facing_changed(_facing: HexOrientation)

func _ready() -> void:
	if parent.has_signal("turn_ended"):
		parent.turn_ended.connect(_on_turn_end)
	if parent.has_signal("setup_started"):
		parent.setup_started.connect(_on_setup)

func set_position(axial: Vector2i):
	_axial_position = axial
	_axial_position = AxialUtilities.axial_clamp(_axial_position, HexGridClass.get_grid_radius())
	parent.position = AxialUtilities.axial_to_world(_axial_position)

func set_facing(value):
	_facing.set_direction(value)
	facing_changed.emit(_facing)

func calculate_velocity() -> Vector2i:
	var new_velocity = _previous_velocity
	for impulse in _impulse_dict.values():
		new_velocity += impulse
	for force in _force_dict.values():
		new_velocity += force
	return new_velocity

func get_velocity_data() -> Dictionary:
	return {
		"previous_velocity": _previous_velocity,
		"impule_dict": _impulse_dict.duplicate(),
		"force_dict": _force_dict.duplicate(),
		"result": calculate_velocity()
	}

func _commit_velocity():
	_previous_velocity = _velocity
	_velocity = calculate_velocity()
	_impulse_dict.clear()

func _register_impact(dict: Dictionary[String, Vector2i], force_name: String):
	if !dict.has(force_name):
		dict[force_name] = Vector2i.ZERO

func _apply_velocity():
	set_position(_axial_position + _velocity)

func add_force(force_name: String, value: Vector2i):
	_register_impact(_force_dict, force_name)
	_force_dict[force_name] += value

func add_impulse(impulse_name: String, value: Vector2i):
	_register_impact(_impulse_dict, impulse_name)
	_impulse_dict[impulse_name] += value

func _on_turn_end(_actor: Actor):
	_commit_velocity()
	_apply_velocity()

func _on_setup(_config: ActorConfig):
	set_position(_config.spawn_point)
	
	#Temporary
	add_force("gravity", Vector2i(0, -1))
