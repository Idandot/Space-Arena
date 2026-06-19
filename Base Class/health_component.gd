extends Node
class_name HealthComponent

signal structure_changed

@export var hex_rigidbody: HexRigidbody
@export var starting_structure: Dictionary[String, int] = {
	"nose": 12,
	"starboard": 15,
	"port": 15,
	"aft": 10,
	"inner structure": 15
}

var structure: Dictionary[String, int]
@onready var parent: Actor = self.get_parent()

func _ready() -> void:
	structure = starting_structure.duplicate()

func take_damage_from_position(amount: int, from_ax: Vector2i) -> void:
	var location: String = get_hit_zone(from_ax)
	var excess_damage: int = 0
	
	structure[location] -= amount
	if structure[location] < 0:
		excess_damage = abs(structure[location])
		structure[location] = 0
	
	GameEvents.log_request.emit(str(parent.display_name, " had taken ",amount-excess_damage, " damage in location ", location))
	GameEvents.log_request.emit(str(structure[location], "/",starting_structure[location]," ",location, " integrity left"))
	
	structure["inner structure"] -= excess_damage
	if structure["inner structure"] <= 0:
		GameEvents.log_request.emit(str(parent.display_name, " is destroyed"))
		parent.kill()
	
	if excess_damage != 0:
		GameEvents.log_request.emit(str(parent.display_name, " had taken ",excess_damage, " damage in inner structure"))
		GameEvents.log_request.emit(str(structure["inner structure"], "/",
		starting_structure["inner structure"], " inner structure integrity left"))
	
	structure_changed.emit()

func get_hit_zone(attacker_position: Vector2i) -> String:
	var to_attacker = attacker_position - hex_rigidbody.axial_position
	var nose_angle = -hex_rigidbody.facing.get_current_angle()
	var port_angle = nose_angle - 90
	var starboard_angle = nose_angle + 90
	
	var attack_direction = AxialUtilities.axial_to_world(to_attacker).normalized()
	var attack_angle = rad_to_deg(attack_direction.angle())
	
	var nose_arc_diff = _angle_difference(nose_angle, attack_angle)
	var port_arc_diff = _angle_difference(port_angle, attack_angle)
	var starboard_arc_diff = _angle_difference(starboard_angle, attack_angle)
	
	if port_arc_diff <= 30 or is_equal_approx(port_arc_diff, 30):
		return "port"
	elif starboard_arc_diff <= 30 or is_equal_approx(starboard_arc_diff, 30):
		return "starboard"
	elif nose_arc_diff <= 90:
		return "nose"
	else:
		return "aft"

func _angle_difference(angle1: float, angle2: float) -> float:
	var diff = fmod(angle2 - angle1, 360.0)
	diff = _angle_normalize(diff)
	return abs(diff)

func _angle_normalize(angle: float) -> float:
	if angle > 180:
		angle -= 360
	elif angle < -180:
		angle += 360
	return angle
