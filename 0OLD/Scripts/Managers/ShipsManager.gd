extends Node

var ships: Array = []

func register(ship):
	if ship in ships:
		print("ship is already registered")
		return
	ships.append(ship)

func unregister(ship):
	if ship not in ships:
		print("ship is not registered")
		return
	ships.erase(ship)
	clean_dead()

func clean_dead():
	
	ships = ships.filter(func(s): return is_instance_valid(s))

func get_alive() -> Array:
	return ships.filter(func(s): return is_instance_valid(s))


















