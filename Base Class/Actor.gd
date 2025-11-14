extends Node
class_name Actor

var _axial_position: Vector2i
var _facing: HexOrientation = HexOrientation.new()

#добавить больше сигналов по необходимости
signal setup_started(config: ActorConfig)
signal turn_ended(actor: Actor)
signal turn_started(actor: Actor)
signal facing_changed(_facing: HexOrientation)

@export var modules: Array[PackedScene] = []

var _initiative = 0
var _is_alive = true

func setup(config: ActorConfig):
	setup_started.emit(config.duplicate())
	if config.spawn_point != null:
		set_position(config.spawn_point)
	if config.initial_facing != null:
		set_facing(config.initial_facing)


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

func set_position(axial: Vector2i):
	_axial_position = axial
	_axial_position = AxialUtilities.axial_clamp(_axial_position, HexGridClass.get_grid_radius())
	self.position = AxialUtilities.axial_to_world(_axial_position)

func set_facing(value):
	_facing.set_direction(value)
	facing_changed.emit(_facing)










