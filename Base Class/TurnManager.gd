extends Node
class_name TurnManager

#Вынести в ресурс в будущем
@export var max_round = 10

var _starting_actors: Array[Actor] = []
var _alive_actors: Array[Actor] = []
var _turn_queue: Array[Actor] = []
var _current_actor: Actor
var _current_round := 0
enum game_states {INACTIVE, ACTIVE}
var _current_game_state := game_states.INACTIVE

#по необходимости добавить сюда сигналы для внешних система

##начинает игровой цикл
func start_game(actors: Array[Actor]) -> void:
	if _current_game_state != game_states.INACTIVE:
		push_warning("Game is already started")
		return
	if actors.is_empty():
		push_error("Cannot start game without actors")
		return
	
	
	_current_game_state = game_states.ACTIVE
	
	_current_round = 1
	
	_starting_actors = actors
	_alive_actors = _starting_actors
	for actor in _starting_actors:
		actor.turn_ended.connect(_on_turn_ended)
	
	print("Turn Manager: turn started with %d actors" % actors.size())
	_create_turn_queue()
	_start_next_turn()

##завершает игровой цикл
func end_game() -> void:
	if _current_game_state == game_states.INACTIVE:
		return
	
	for actor in _starting_actors:
		actor.turn_ended.disconnect(_on_turn_ended)
	
	_current_game_state = game_states.INACTIVE
	
	_current_round = 0
	_current_actor = null
	
	_starting_actors = []
	_alive_actors = []
	_turn_queue = []
	
	print("Turn Manager: game ended")
	#Возвращаем TurnManager в изначальное состояние чтобы если что ничего не приключилось
	#Если в будущем нужна инфа об окончании игры, сигналы лучше вставлять перед сбросом

func _start_next_turn():
	if _current_game_state != game_states.ACTIVE:
		push_warning("Game isn't active")
		return
	if _turn_queue.is_empty():
		_current_round += 1
		if _current_round > max_round:
			end_game()
			return
		_create_turn_queue()
		if _turn_queue.is_empty():
			end_game()
			return
	
	_current_actor = _turn_queue[0]
	_turn_queue.remove_at(0)
	_current_actor.take_turn()

func _on_turn_ended(actor: Actor):
	if _current_game_state != game_states.ACTIVE:
		push_warning("Game isn't active")
		return
	
	if _current_actor != actor:
		push_warning("Received turn end from wrong actor")
		return
	
	_check_victory_conditions()
	_start_next_turn()

func _get_current_actor() -> Actor:
	return _current_actor

func _check_victory_conditions():
	push_error("this func isn't written!")

func _sort_actors_by_initiative(actors: Array[Actor]) -> Array[Actor]:
	if actors.size() <= 1:
		return actors
	
	actors.sort_custom(_compare_initiative)
	
	return actors

func _compare_initiative(a: Actor, b: Actor) -> bool:
	
	return a.get_initiative() > b.get_initiative()

func _create_turn_queue():
	_alive_actors = _starting_actors.filter(func(a): return a.is_alive())
	
	_alive_actors = _sort_actors_by_initiative(_alive_actors)
	
	_turn_queue = _alive_actors.duplicate()






