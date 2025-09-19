extends Node2D

var ships := []
var current_index := 0

func start_game(ships_list: Array):
	ships = ships_list
	current_index = 0
	start_turn()

func start_turn():
	await get_tree().process_frame
	var ship = ships[current_index]
	if !ship.is_connected("turn_ended", Callable(self, "_on_ship_turn_finished")):
		ship.connect("turn_ended", Callable(self, "_on_ship_turn_finished"), CONNECT_ONE_SHOT)
	ship.take_turn()

func _on_ship_turn_finished():
	current_index = (current_index + 1) % ships.size()
	start_turn()
