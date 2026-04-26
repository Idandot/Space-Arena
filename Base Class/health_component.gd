extends Node
class_name HealthComponent

@export var max_health = 20
var health

@onready var parent: Actor = self.get_parent()

func _ready() -> void:
	health = max_health

func take_damage(amount: int) -> void:
	GameEvents.log_request.emit(str(parent.display_name, " had taken ",amount, " damage"))
	health -= amount
	GameEvents.log_request.emit(str(health, "/",max_health, " hp left"))
	if health <= 0:
		GameEvents.log_request.emit(str(parent.display_name, " is ded"))
		parent.kill()
