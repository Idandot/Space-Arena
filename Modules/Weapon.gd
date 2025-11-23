extends Module
class_name Weapon

func _fire():
	return

func get_available_actions() -> Array[Action]:
	return [
		#Action.new("weapon_fire", _fire, Enums.turn_phase.ACTION, "fire")
	]
