extends Node
class_name HealthComponent

@onready var parent: Actor = self.get_parent()

func take_damage(amount: int) -> void:
	GameEvents.log_request.emit(str(parent.display_name, " had taken ",amount, " damage"))
