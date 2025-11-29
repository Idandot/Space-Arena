extends Controller
class_name PlayerController

#ПУБЛИЧНЫЕ МЕТОДЫ

##Возвращает доступные действия модуля
func get_available_actions() -> Array[Action]:
	return [
		Action.new("end_movement_turn", _end_turn, Enums.game_states.MOVEMENT, "end_turn"),
		Action.new("end_action_turn", _end_turn, Enums.game_states.ACTION, "end_turn")
	]

#ОСНОВНЫЕ МЕТОДЫ

func _ready() -> void:
	super._ready()
	_module_name = "controller"

func _process(_delta: float) -> void:
	if _should_handle_input():
		_handle_input()

##Вызывается в начале хода актера
func _take_control(_actor: Actor, _phase: Enums.game_states) -> void:
	var actions = ship_layout.collect_actions()
	for action in actions:
		if !action.callback.is_valid():
			continue
		_actions[action.action_name] = action

#ДЕЙСТВИЯ МОДУЛЯ

##Завершает ход
func _end_turn() -> void:
	parent.end_turn()

#ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ

##Отвечает за принятие ввода от игрока
func _handle_input() -> void:
	for action in _actions.values():
		if !_is_action_available(action):
			continue
		if Input.is_action_just_pressed(action.input_action):
			action.callback.call()

##Сверяем фазу для действия с текущей фазой
func _is_action_available(action: Action) -> bool:
	return action.applicable_state == TurnManager._current_game_state

##Сверяемся с тем может ли в текущей фазе актер выполнять действия
func _should_handle_input() -> bool:
	return parent.is_active
