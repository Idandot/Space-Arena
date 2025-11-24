extends Controller
class_name PlayerController

var turn_phase: Enums.turn_phase = Enums.turn_phase.MOVEMENT:
	set(value):
		turn_phase = value
		GameEvents.phase_changed.emit(parent, turn_phase)
		print(parent.display_name, "'s turn phase changed to ", turn_phase)
	get:
		return turn_phase

#ПУБЛИЧНЫЕ МЕТОДЫ

##Возвращает доступные действия модуля
func get_available_actions() -> Array[Action]:
	return [
		Action.new("end_movement_phase", _end_movement_phase, Enums.turn_phase.MOVEMENT, "end_phase"),
		Action.new("end_action_phase", _end_action_phase, Enums.turn_phase.ACTION, "end_phase")
	]

#ОСНОВНЫЕ МЕТОДЫ

func _ready() -> void:
	super._ready()
	_module_name = "controller"
	ship_mediator.movement_animation_finished.connect(_on_movement_animation_finished)

func _process(_delta: float) -> void:
	if _should_handle_input():
		_handle_input()

##Вызывается в начале хода актера
func _take_control(_actor: Actor) -> void:
	var actions = ship_mediator.collect_actions()
	for action in actions:
		if !action.callback.is_valid():
			continue
		_actions[action.action_name] = action
	
	turn_phase = Enums.turn_phase.MOVEMENT

#ДЕЙСТВИЯ МОДУЛЯ

##Завершает фазу движения
func _end_movement_phase() -> void:
	ship_mediator.call_planning_completed()

##Завершает фазу действий
func _end_action_phase() -> void:
	parent.end_turn()

#ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ

##Отвечает за принятие ввода от игрока
func _handle_input() -> void:
	for action in _actions.values():
		if !_is_action_available(action):
			continue
		if Input.is_action_just_pressed(action.input_action):
			action.callback.call()

##Обработка сигнала от Visualizer
func _on_movement_animation_finished() -> void:
	turn_phase = Enums.turn_phase.ACTION
	parent.state = Enums.actor_states.ACTIVE
	return

##Сверяем фазу для действия с текущей фазой
func _is_action_available(action: Action) -> bool:
	return action.applicable_state == turn_phase

##Сверяемся с тем может ли в текущей фазе актер выполнять действия
func _should_handle_input() -> bool:
	return parent.state == Enums.actor_states.ACTIVE
