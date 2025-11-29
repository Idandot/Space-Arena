extends Node
class_name UIManager

@export var thrust_label: Label
@export var round_label: Label
@export var phase_label: Label
@export var actor_label: Label
@export var game_log_label: RichTextLabel

func _ready() -> void:
	GameEvents.thrust_changed.connect(_update_thrust_label)
	GameEvents.round_changed.connect(_update_round_label)
	GameEvents.log_request.connect(_log_message)
	TurnManager.phase_started.connect(_update_phase_label)
	TurnManager.action_turn_started.connect(_update_actor_label)
	TurnManager.movement_turn_started.connect(_update_actor_label)

func _update_thrust_label(_actor: Actor, thrust: int, max_thrust: int):
	if !thrust_label:
		return
	thrust_label.text = "Thrust: %s/%s" % [thrust, max_thrust]

func _update_round_label(current_round: int, max_round: int):
	if !round_label:
		return
	round_label.text = "Round: %s/%s" % [current_round, max_round]

func _update_phase_label(phase: Enums.game_states):
	if !phase_label:
		return
	var phase_str: String = ""
	match phase:
		Enums.game_states.MOVEMENT:
			phase_str = "Movement"
		Enums.game_states.ACTION:
			phase_str = "Action"
		Enums.game_states.PHYSICS:
			phase_str = "Physics"
			if actor_label:
				actor_label.text = ""
		_:
			phase_str = "?"
	phase_label.text = "%s phase" % phase_str

func _update_actor_label(actor: Actor):
	if !actor_label:
		return
	actor_label.text = "%s's turn" % actor.display_name

func _log_message(message: String):
	if !game_log_label:
		return
	game_log_label.add_text(message + "\n")
