extends Node
class_name Actor

var _axial_position: Vector2i

#добавить больше сигналов по необходимости
signal turn_ended(actor)

@export var modules: Array[PackedScene] = []

var _initiative = 0
var _is_alive = true

func take_turn():
	end_turn()

func start_movement_phase():
	pass

func end_turn():
	emit_signal("turn_ended", self)

func get_initiative():
	return _initiative

func is_alive():
	return _is_alive

func set_position_world(world: Vector2):
	self.position = world
	_axial_position = AxialUtilities.world_to_axial(world)
	if AxialUtilities.distance(_axial_position) > HexGridClass.get_grid_radius():
		print("out of bounds")

func set_position_axial(axial: Vector2i):
	_axial_position = axial
	self.position = AxialUtilities.axial_to_world(axial)













