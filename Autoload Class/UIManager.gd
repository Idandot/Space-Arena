extends Node
class_name UIManager

@export var thrust_label: Label
@export var round_label: Label
@export var phase_label: Label

func _ready() -> void:
	GameEvents.thrust_changed.connect(_update_thrust_label)
	GameEvents.round_changed.connect(_update_round_label)
	GameEvents.phase_changed.connect(_update_phase_label)

func _update_thrust_label(_actor: Actor, thrust: int, max_thrust: int):
	if !thrust_label:
		return
	thrust_label.text = "Thrust: %s/%s" % [thrust, max_thrust]

func _update_round_label(current_round: int, max_round: int):
	if !round_label:
		return
	round_label.text = "Round: %s/%s" % [current_round, max_round]

func _update_phase_label(actor: Actor, phase: Enums.turn_phase):
	if !phase_label:
		return
	var phase_str: String = ""
	match phase:
		Enums.turn_phase.MOVEMENT:
			phase_str = "movement"
		Enums.turn_phase.ACTION:
			phase_str = "action"
	phase_label.text = "%s's %s phase" % [actor.display_name, phase_str]
