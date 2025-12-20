extends Node

@export var physics_phase_duration: float = 0.5

var _starting_actors: Array[Actor] = []
var _phase_queue: Array[Actor] = []
var _current_actor: Actor
var _current_round := 0
var _max_round := 10

var current_game_state := Enums.game_states.INACTIVE:
	get():
		return current_game_state
	set(value):
		current_game_state = value
var alive_actors: Array[Actor] = []:
	set(value):
		alive_actors = value
	get:
		return alive_actors

enum end_game_reason {ROUND_LIMIT, ALL_DEAD, LAST_STANDING, MANUAL}

signal game_started(game_config: GameConfig)
signal round_started(new_round: int)
signal phase_started(phase: Enums.game_states)
signal game_ended(reason: String)
signal turn_started(actor: Actor, phase: Enums.game_states)

#ПУБЛИЧНЫЕ МЕТОДЫ

##начинает игровой цикл
func start_game(actors: Array[Actor], game_config: GameConfig) -> void:
	if current_game_state != Enums.game_states.INACTIVE:
		push_warning("Game is already started")
		return
	if actors.is_empty():
		push_error("Cannot start game without actors")
		return
	
	_max_round = game_config.max_round
	
	current_game_state = Enums.game_states.MOVEMENT
	_current_round = 0
	
	_starting_actors = actors
	alive_actors = _starting_actors
	for actor in _starting_actors:
		actor.turn_ended.connect(_on_turn_ended)
		actor.killed.connect(_on_actor_killed)
	
	_start_next_round()
	
	game_started.emit(game_config)

##завершает игровой цикл
func end_game(eg_reason: end_game_reason) -> void:
	if current_game_state == Enums.game_states.INACTIVE:
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
	
	current_game_state = Enums.game_states.INACTIVE
	
	_current_round = 0
	_current_actor = null
	
	_starting_actors = []
	alive_actors = []
	_phase_queue = []
	
	#Возвращаем TurnManager в изначальное состояние чтобы если что ничего не приключилось
	#Если в будущем нужна инфа об окончании игры, сигналы лучше вставлять перед сбросом

##выдает челика чей сейчас ход
func get_current_actor_or_null() -> Actor:
	if current_game_state in [Enums.game_states.INACTIVE, Enums.game_states.PHYSICS]:
		return null
	return _current_actor

#ПРИВАТНЫЕ МЕОТДЫ ДЛЯ УПРАВЛЕНИЯ СОСТОЯНИЕМ

##Начинает следующий раунд
func _start_next_round():
	if current_game_state == Enums.game_states.INACTIVE:
		push_warning("Game isn't active")
		return
	
	_current_round += 1
	if _current_round > _max_round:
		end_game(end_game_reason.ROUND_LIMIT)
		return
	
	alive_actors = _starting_actors.filter(func(a): return a.is_alive())
	if alive_actors.is_empty():
		end_game(end_game_reason.ALL_DEAD)
		return
	
	round_started.emit(_current_round)
	GameEvents.round_changed.emit(_current_round, _max_round)
	
	_start_movement_phase()

func _start_movement_phase():
	
	_phase_queue = _create_phase_queue(current_game_state)
	
	current_game_state = Enums.game_states.MOVEMENT
	phase_started.emit(current_game_state)
	
	_start_next_turn()

func _start_physics_phase():
	
	current_game_state = Enums.game_states.PHYSICS
	phase_started.emit(current_game_state)
	
	await get_tree().create_timer(physics_phase_duration).timeout
	
	_start_next_phase()

func _start_action_phase():
	
	_phase_queue = _create_phase_queue(current_game_state)
	
	current_game_state = Enums.game_states.ACTION
	phase_started.emit(current_game_state)
	
	_start_next_turn()

func _start_next_phase():
	#Вот это клоака
	match current_game_state:
		Enums.game_states.MOVEMENT:
			_start_physics_phase()
		Enums.game_states.PHYSICS:
			_start_action_phase()
		Enums.game_states.ACTION:
			_start_next_round()
		Enums.game_states.INACTIVE:
			push_warning("Game isn't active")
			return
		_:
			push_error("BLYAT")

func _start_next_turn():
	if _phase_queue.is_empty():
		_start_next_phase()
		return
	
	_current_actor = _phase_queue[0]
	_phase_queue.remove_at(0)
	_current_actor.take_turn(current_game_state)
	turn_started.emit(_current_actor, current_game_state)

#ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ

func _create_phase_queue(for_phase: Enums.game_states) -> Array[Actor]:
	var queue = _sort_actors_by_initiative(alive_actors, for_phase).duplicate()
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
	if current_game_state == Enums.game_states.INACTIVE:
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

func _on_actor_killed(killed_actor: Actor):
	if killed_actor == _current_actor:
		match current_game_state:
			Enums.game_states.MOVEMENT:
				_start_movement_phase()
			Enums.game_states.ACTION:
				_start_action_phase()
