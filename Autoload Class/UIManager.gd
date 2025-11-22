extends Node
class_name UIManager

@export var thrust_label: Label

func _ready() -> void:
	GameEvents.thrust_changed.connect(_update_thrust_label)

func _update_thrust_label(_actor: Actor, thrust: int, max_thrust: int):
	if !thrust_label:
		return
	thrust_label.text = "thrust: " + str(thrust) + "/" + str(max_thrust)
