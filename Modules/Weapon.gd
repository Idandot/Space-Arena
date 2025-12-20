extends Module
class_name Weapon

var target: Actor = null
@export var damage: int = 5

func get_available_actions() -> Array[Action]:
	return [
		Action.new("weapon_fire", _fire, Enums.game_states.ACTION, "fire")
	]

func _fire():
	target = _find_target()
	if !target.has_node("HealthComponent"):
		print("цель не может получить урон")
		return
	target.get_node("HealthComponent").take_damage(damage)

func _find_target() -> Actor:
	var alive_actors = TurnManager.alive_actors
	var best_target: Actor = null
	
	#временный код, в будущем поиск цели будет реализован более сложно
	for actor in alive_actors:
		if actor.display_name != parent.display_name:
			best_target = actor
	
	return best_target
