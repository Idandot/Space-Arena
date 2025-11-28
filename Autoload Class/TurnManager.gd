extends Node

var _starting_actors: Array[Actor] = []
var _alive_actors: Array[Actor] = []
var _phase_queue: Array[Actor] = []
var _current_actor: Actor
var _current_round := 0
var _max_round := 10
var _current_game_state := Enums.game_states.INACTIVE
enum end_game_reason {ROUND_LIMIT, ALL_DEAD, LAST_STANDING, MANUAL}

signal game_started(game_config: GameConfig)
signal round_started(new_round: int)
signal phase_started(phase: Enums.game_states)
signal movement_turn_started(actor: Actor)
signal action_turn_started(actor: Actor)
signal game_ended(reason: String)

##начинает игровой цикл
func start_game(actors: Array[Actor], game_config: GameConfig) -> void:
	if _current_game_state != Enums.game_states.INACTIVE:
		push_warning("Game is already started")
		return
	if actors.is_empty():
		push_error("Cannot start game without actors")
		return
	
	_max_round = game_config.max_round
	
	_current_game_state = Enums.game_states.MOVEMENT
	_current_round = 0
	
	_starting_actors = actors
	_alive_actors = _starting_actors
	for actor in _starting_actors:
		actor.turn_ended.connect(_on_turn_ended)
		actor.killed.connect(_on_actor_killed)
	
	print("Turn Manager: game started with %d actors" % actors.size())
	_start_next_round()
	
	game_started.emit(game_config)

##завершает игровой цикл
func end_game(eg_reason: end_game_reason) -> void:
	if _current_game_state == Enums.game_states.INACTIVE:
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
	
	_current_game_state = Enums.game_states.INACTIVE
	
	_current_round = 0
	_current_actor = null
	
	_starting_actors = []
	_alive_actors = []
	_phase_queue = []
	
	print("Turn Manager: game ended")
	#Возвращаем TurnManager в изначальное состояние чтобы если что ничего не приключилось
	#Если в будущем нужна инфа об окончании игры, сигналы лучше вставлять перед сбросом

##выдает челика чей сейчас ход
func get_current_actor_or_null() -> Actor:
	if _current_game_state in [Enums.game_states.INACTIVE, Enums.game_states.PHYSICS]:
		return null
	return _current_actor

func get_current_phase() -> Enums.game_states:
	return _current_game_state

func _start_next_round():
	if _current_game_state == Enums.game_states.INACTIVE:
		push_warning("Game isn't active")
		return
	
	_current_round += 1
	if _current_round > _max_round:
		end_game(end_game_reason.ROUND_LIMIT)
		return
	
	_alive_actors = _starting_actors.filter(func(a): return a.is_alive())
	if _alive_actors.is_empty():
		end_game(end_game_reason.ALL_DEAD)
		return
	
	round_started.emit(_current_round)
	GameEvents.round_changed.emit(_current_round, _max_round)
	print("Turn Manager: round ", _current_round, " started")
	
	_start_movement_phase()

func _start_movement_phase():
	if _current_game_state == Enums.game_states.INACTIVE:
		push_warning("Game isn't active")
		return
	
	_phase_queue = _create_phase_queue(_current_game_state)
	
	_current_game_state = Enums.game_states.MOVEMENT
	phase_started.emit(_current_game_state)
	print("Turn Manager: movement phase started")
	
	_start_next_movement_turn()

func _start_physics_phase():
	if _current_game_state == Enums.game_states.INACTIVE:
		push_warning("Game isn't active")
		return
	
	_current_game_state = Enums.game_states.PHYSICS
	phase_started.emit(_current_game_state)
	print("Turn Manager: physics phase started")
	
	await get_tree().create_timer(0.1).timeout
	#Дождаться всех анимаций
	
	_start_action_phase()

func _start_action_phase():
	if _current_game_state == Enums.game_states.INACTIVE:
		push_warning("Game isn't active")
		return
	
	_phase_queue = _create_phase_queue(_current_game_state)
	
	_current_game_state = Enums.game_states.PHYSICS
	phase_started.emit(_current_game_state)
	print("Turn Manager: action phase started")
	
	_start_next_action_turn()

func _start_next_movement_turn():
	if _phase_queue.is_empty():
		_start_physics_phase()
		return
	
	_current_actor = _phase_queue[0]
	_phase_queue.remove_at(0)
	_current_actor.take_turn(_current_game_state)
	movement_turn_started.emit(_current_actor)

func _start_next_action_turn():
	if _phase_queue.is_empty():
		_start_next_round()
		return
	
	_current_actor = _phase_queue[0]
	_phase_queue.remove_at(0)
	_current_actor.take_turn(_current_game_state)
	action_turn_started.emit(_current_actor)

func _create_phase_queue(for_phase: Enums.game_states) -> Array[Actor]:
	var queue = _sort_actors_by_initiative(_alive_actors, for_phase).duplicate()
	return queue

func _sort_actors_by_initiative(actors: Array[Actor], _phase: Enums.game_states) -> Array[Actor]:
	#В будущем ввести разную сортировку в зависимости от текущей фазы
	
	if actors.size() <= 1:
		return actors
	
	actors.sort_custom(_compare_initiative)
	
	return actors

func _compare_initiative(a: Actor, b: Actor) -> bool:
	return a.get_initiative() > b.get_initiative()

func _on_turn_ended(actor: Actor):
	if _current_game_state == Enums.game_states.INACTIVE:
		push_warning("Game isn't active")
		return
	
	if _current_actor != actor:
		push_warning("Received turn end from wrong actor")
		return
	
	_check_victory_conditions()
	match _current_game_state:
		Enums.game_states.MOVEMENT:
			_start_next_movement_turn()
		Enums.game_states.ACTION:
			_start_next_action_turn()

func _check_victory_conditions():
	#В будущем реализую
	pass

func _on_actor_killed(killed_actor: Actor):
	if killed_actor == _current_actor:
		match _current_game_state:
			Enums.game_states.MOVEMENT:
				_start_movement_phase()
			Enums.game_states.ACTION:
				_start_action_phase()
