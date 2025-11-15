extends Node
class_name HexRigidbody

var _facing = HexOrientation.new()
var _axial_position = Vector2i.ZERO
#var _velocity = Vector2i.ZERO
#var _velocities: Array[Vector2i] = []
#var _acceleration = Vector2i.ZERO
#var _accelerations: Array[Vector2i] = []

@onready var parent: Node2D = self.get_parent()
@onready var event_bus: Node
#You stopped here

signal facing_changed(_facing: HexOrientation)

func set_position(axial: Vector2i):
	_axial_position = axial
	_axial_position = AxialUtilities.axial_clamp(_axial_position, HexGridClass.get_grid_radius())
	self.position = AxialUtilities.axial_to_world(_axial_position)

func set_facing(value):
	_facing.set_direction(value)
	facing_changed.emit(_facing)
