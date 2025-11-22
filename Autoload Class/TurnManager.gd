extends Node
class_name TurnManager

var _starting_actors: Array[Actor] = []
var _alive_actors: Array[Actor] = []
var _turn_queue: Array[Actor] = []
var _current_actor: Actor
var _current_round := 0
var _max_round := 10
var _current_game_state := game_states.INACTIVE

enum game_states {INACTIVE, ACTIVE}
enum end_game_reason {ROUND_LIMIT, ALL_DEAD, LAST_STANDING, MANUAL}

signal game_started(game_config: GameConfig)
signal round_started(new_round: int)
signal turn_started(actor: Actor)
signal game_ended(reason: String)

##начинает игровой цикл
func start_game(actors: Array[Actor], game_config: GameConfig) -> void:
	#Для задержки начала игры, если нужно снять видео
	#await get_tree().create_timer(2).timeout
	if _current_game_state != game_states.INACTIVE:
		push_warning("Game is already started")
		return
	if actors.is_empty():
		push_error("Cannot start game without actors")
		return
	
	if game_config.has_meta("max_round"):
		_max_round = game_config.max_round
	
	_current_game_state = game_states.ACTIVE
	
	_current_round = 0
	
	_starting_actors = actors
	_alive_actors = _starting_actors
	for actor in _starting_actors:
		actor.turn_ended.connect(_on_turn_ended)
		actor.killed.connect(_on_actor_killed)
	
	print("Turn Manager: game started with %d actors" % actors.size())
	_start_next_turn()
	
	game_started.emit(game_config)

##завершает игровой цикл
func end_game(eg_reason: end_game_reason) -> void:
	if _current_game_state == game_states.INACTIVE:
		return
	
	for actor in _starting_actors:
		actor.turn_ended.disconnect(_on_turn_ended)
	
	var reason: String = ""
	match eg_reason:
		end_game_reason.ROUND_LIMIT:
			reason = "Round limit"
		end_game_reason.ALL_DEAD:
			reason = "All dead"
		end_game_reason.LAST_STANDING:
			reason = "Last standing"
		_:
			reason = "Manual"
	game_ended.emit(reason)
	
	_current_game_state = game_states.INACTIVE
	
	_current_round = 0
	_current_actor = null
	
	_starting_actors = []
	_alive_actors = []
	_turn_queue = []
	
	print("Turn Manager: game ended")
	#Возвращаем TurnManager в изначальное состояние чтобы если что ничего не приключилось
	#Если в будущем нужна инфа об окончании игры, сигналы лучше вставлять перед сбросом

##выдает челика чей сейчас ход
func get_current_actor() -> Actor:
	return _current_actor

func _start_next_turn():
	if _current_game_state != game_states.ACTIVE:
		push_warning("Game isn't active")
		return
	if _turn_queue.is_empty():
		_current_round += 1
		if _current_round > _max_round:
			end_game(end_game_reason.ROUND_LIMIT)
			return
		_create_turn_queue()
		if _turn_queue.is_empty():
			end_game(end_game_reason.ALL_DEAD)
			return
		round_started.emit(_current_round)
		print("Turn Manager: round ", _current_round, " started")
	
	_current_actor = _turn_queue[0]
	_turn_queue.remove_at(0)
	_current_actor.take_turn()
	turn_started.emit(_current_actor)

func _on_turn_ended(actor: Actor):
	if _current_game_state != game_states.ACTIVE:
		push_warning("Game isn't active")
		return
	
	if _current_actor != actor:
		push_warning("Received turn end from wrong actor")
		return
	
	
	_check_victory_conditions()
	_start_next_turn()

func _check_victory_conditions():
	#В будущем реализую
	pass

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

func _on_actor_killed(killed_actor: Actor):
	if killed_actor == _current_actor:
		_start_next_turn()
