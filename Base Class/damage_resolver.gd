extends Node
class_name DamageResolver

enum LOCATION { NOSE, AFT, PORT, STARBOARD }

signal structure_changed(location: String, modules: Array[Module])

@export var hex_rigidbody: HexRigidbody
@export var starting_structure: ArmorConfig

var structure: ArmorConfig
var actor: Actor

@onready var _ship_layout: ShipLayout = self.get_parent()

var location_to_string: Dictionary[LOCATION, String] = {
	LOCATION.NOSE: "nose",
	LOCATION.AFT: "aft",
	LOCATION.PORT: "port",
	LOCATION.STARBOARD: "starboard",
}

func _ready() -> void:
	actor = _ship_layout.get_parent()
	actor.setup_started.connect(_setup)
	actor.damage_taken.connect(_take_damage_from_position)

func _setup(config: ActorConfig) -> void:
	starting_structure = config.armor_config
	structure = starting_structure.duplicate()

#Основная логика урона
func _take_damage_from_position(amount: int, from_ax: Vector2i) -> void:
	var location: LOCATION = get_hit_zone(from_ax)
	var location_str: String = location_to_string[location]
	
	var actual_damage: int = min(amount, structure[location_str])
	var excess_damage: int = amount - actual_damage
	structure[location_str] -= actual_damage
	
	GameEvents.log_request.emit("%s took %d damage in %s. Integrity: %d/%d" % [
		actor.display_name, actual_damage, location_str,
		structure[location_str], starting_structure[location_str]
	])
	
	if excess_damage == 0:
		structure_changed.emit(location_str, [] as Array[Module])
		return
	
	var damage_path: Array[Vector2i] = _calculate_damage_path(location)
	var damaged_modules: Array[Module] = []
	for grid_pos in damage_path:
		var module = _ship_layout.get_module_or_null(grid_pos)
		if module == null:
			continue
		
		excess_damage = module.take_damage(excess_damage)
		damaged_modules.append(module)
		if excess_damage == 0:
			break
	
	structure_changed.emit(location_str, damaged_modules)

func _calculate_damage_path(location: LOCATION) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	var grid: Rect2i = _ship_layout.get_grid_rect()
	
	var min_pos: Vector2i = grid.position
	var max_pos: Vector2i = grid.position + grid.size - Vector2i.ONE
	
	var start_pos: Vector2i
	var step: Vector2i
	var step_count: int
	
	match location:
		LOCATION.NOSE:
			start_pos = Vector2i(randi_range(min_pos.x, max_pos.x), max_pos.y)
			step = Vector2i(0, -1)
			step_count = grid.size.y
		LOCATION.AFT:
			start_pos = Vector2i(randi_range(min_pos.x, max_pos.x), min_pos.y)
			step = Vector2i(0, 1)
			step_count = grid.size.y
		LOCATION.STARBOARD:
			start_pos = Vector2i(max_pos.x, randi_range(min_pos.y, max_pos.y))
			step = Vector2i(-1, 0)
			step_count = grid.size.x
		LOCATION.PORT:
			start_pos = Vector2i(min_pos.x, randi_range(min_pos.y, max_pos.y))
			step = Vector2i(1, 0)
			step_count = grid.size.x
		_:
			push_error("DamageResolver: Invalid location for damage path")
			return path
	
	for i in step_count:
		path.append(start_pos + step * i)
	
	return path

func get_hit_zone(attacker_position: Vector2i) -> LOCATION:
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
		return LOCATION.PORT
	elif starboard_arc_diff <= 30 or is_equal_approx(starboard_arc_diff, 30):
		return LOCATION.STARBOARD
	elif nose_arc_diff <= 90:
		return LOCATION.NOSE
	else:
		return LOCATION.AFT

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
