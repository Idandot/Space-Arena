extends Node

@warning_ignore("unused_signal")
signal thrust_changed(actor: Actor, thrust: int, max_thrust: int)
@warning_ignore("unused_signal")
signal round_changed(round: int, max_round: int)
@warning_ignore("unused_signal")
signal phase_changed(actor: Actor, phase: Enums.turn_phase)
