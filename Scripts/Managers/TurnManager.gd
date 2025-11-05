extends Node2D

var current_index := 0
@onready var Root = get_parent().get_parent()
@onready var BEM = BattleEventManager
@onready var ships = ShipsManager.ships

func start_game():
	current_index = 0
	start_turn()

func start_turn():
	await get_tree().process_frame
	var ship = ShipsManager.ships[current_index]
	
	if !is_instance_valid(ship):
		_on_ship_turn_finished()
		return
	
	if !ship.is_connected("turn_ended", Callable(self, "_on_ship_turn_finished")):
		ship.connect("turn_ended", Callable(self, "_on_ship_turn_finished"), CONNECT_ONE_SHOT)
	if !ship.is_connected("destroyed", Callable(self, "_on_ship_destroyed")):
		ship.connect("destroyed", Callable(self, "_on_ship_destroyed"), CONNECT_ONE_SHOT)
	ship.take_turn()
	Root.turn_label.text = ship.name_in_game + "'s movement phase"

func _on_ship_turn_finished():
	current_index = (current_index + 1) % ShipsManager.ships.size()
	start_turn()

func _on_ship_destroyed(destroyed_ship):
	ShipsManager.unregister(destroyed_ship)
	
	#Victory check
	var first_team = ShipsManager.ships[0].team_id
	
	for ship in ShipsManager.ships:
		if !is_instance_valid(ship):
			continue
		if ship.team_id != first_team:
			return
	
	BEM.battle_log(["team ", first_team, " has won"], "Critical")
	for ship in ShipsManager.get_alive():
		ship.Destroy(false)
