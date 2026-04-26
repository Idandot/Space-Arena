extends Module
class_name Weapon

@export var weapon_stats: Dictionary[String, Variant] = {
	"name": "Big Laser",
	"damage": 5,
	"max_range": 6,
	"min_range": 3,
	"arc_degrees": 120,
	"facing_offset": 1, #поворотов на 60 градусов по часовой
}
@export var hex_rigidbody: HexRigidbody

func _ready() -> void:
	module_name = weapon_stats["name"]

func get_available_actions() -> Array[Action]:
	return [
		Action.new("weapon_fire", _fire, Enums.game_states.ACTION, "fire")
	]

func _fire():
	var target: Actor = _find_target()
	if target == null:
		GameEvents.log_request.emit("No target available")
		return
	if !target.has_node("HealthComponent"):
		print("цель не может получить урон")
		return
	target.get_node("HealthComponent").take_damage(weapon_stats["damage"])

func _find_target() -> Actor:
	var alive_actors = TurnManager.alive_actors
	var best_target: Actor = null
	
	#временный код, в будущем поиск цели будет реализован более сложно
	for actor in alive_actors:
		if actor.display_name == parent.display_name:
			continue
		if !actor.has_node("/HexRigidbody"):
			continue
		var target_rigidbody: HexRigidbody = actor.find_child("HexRigidbody")
		if !_is_in_arc(target_rigidbody.axial_position):
			continue
		best_target = actor
	
	return best_target

func _is_in_arc(target_pos: Vector2i) -> bool:
	
	for hex in get_arc_hexes():
		if hex == target_pos:
			return true
	return false

func get_arc_hexes() -> Array[Vector2i]:
	if !hex_rigidbody:
		return []
	var origin = hex_rigidbody.axial_position
	print(parent.display_name, weapon_stats["name"], origin)
	var weapon_facing: HexOrientation = HexOrientation.new()
	weapon_facing.set_direction(weapon_stats["facing_offset"]+hex_rigidbody.facing.get_current_index())
	return AxialUtilities.hexes_in_sector(origin, weapon_facing.get_current_vector(), 
	weapon_stats["arc_degrees"], weapon_stats["min_range"], weapon_stats["max_range"])
