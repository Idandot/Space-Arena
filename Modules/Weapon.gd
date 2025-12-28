extends Module
class_name Weapon

var target: Actor = null
@export var weapon_stats: Dictionary[String, Variant] = {
	"damage": 5,
	"max_range": 6,
	"min_range": 3,
	"arc_degrees": 120,
	"facing_offset": 1, #поворотов на 60 градусов по часовой
}
@export var hex_rigidbody: HexRigidbody

func get_available_actions() -> Array[Action]:
	return [
		Action.new("weapon_fire", _fire, Enums.game_states.ACTION, "fire")
	]

func _fire():
	target = _find_target()
	if !target.has_node("HealthComponent"):
		print("цель не может получить урон")
		return
	target.get_node("HealthComponent").take_damage(weapon_stats["damage"])

func _find_target() -> Actor:
	var alive_actors = TurnManager.alive_actors
	var best_target: Actor = null
	
	#временный код, в будущем поиск цели будет реализован более сложно
	for actor in alive_actors:
		if actor.display_name != parent.display_name:
			best_target = actor
	
	return best_target

func _is_in_arc(target_pos: Vector2i) -> bool:
	if !hex_rigidbody:
		return false
	var origin = hex_rigidbody.axial_position
	var facing = hex_rigidbody.getfacing()
	var hexes_in_sector: Array[Vector2i] = AxialUtilities.hexes_in_sector(origin, facing)
	
	for hex in hexes_in_sector:
		if hex == target_pos:
			return true
	return false
