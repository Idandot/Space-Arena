extends Node
class_name ShipLayout

@export var ship_controller: Controller
@export var modules: Dictionary[Vector2i, Module]
var parent: Actor

#Централизованное управление оружием
var _weapons: Array[Weapon] = []
var _current_weapon_index: int = -1

func collect_actions() -> Array[Action]:
	var actions: Array[Action] = []
	for module in modules.values():
		actions.append_array(module.get_available_actions())
	
	var owc = _get_operational_weapons_count()
	if owc > 0:
		actions.append(Action.new("fire_current_weapon", _fire_current_weapon, Enums.game_states.ACTION, "fire"))
		
		if owc > 1:
			actions.append(Action.new("next_weapon", _next_weapon, Enums.game_states.ACTION, "next_weapon"))
	
	return actions

func _ready() -> void:
	parent = self.get_parent()
	ship_controller = _find_controller()
	TurnManager.turn_started.connect(_on_action_phase_turn_started)
	
	_weapons = get_weapons()
	_select_next_operational_weapon()

func _find_controller() -> Controller:
	var controllers = get_modules_by_tag(Enums.module_tags.CONTROLLER)
	if controllers.size() != 1:
		push_warning("There must be 1 Controller at ship")
	modules[Vector2i.ZERO] = controllers[0]
	return controllers[0]

func get_module_or_null(position: Vector2i) -> Module:
	if modules.has(position):
		return modules[position]
	print("Position is empty")
	return null

func get_modules_by_tag(tag: Enums.module_tags) -> Array[Module]:
	var result: Array[Module] = []
	for module: Module in modules.values():
		var tags = module.tags
		if tags.has(tag):
			result.append(module)
	return result

func get_weapons() -> Array[Weapon]:
	var result: Array[Weapon] = []
	for module: Module in modules.values():
		if module is Weapon:
			result.append(module)
	return result

func _on_action_phase_turn_started(_actor, phase: Enums.game_states):
	if phase != Enums.game_states.ACTION:
		HexGridClass.highlight([], Color.GREEN, false, true)
		return
	if _actor != parent:
		return
	
	await get_tree().process_frame
	
	_update_weapon_highlight()

#ДЕЙСТВИЯ

func _fire_current_weapon() -> void:
	if _current_weapon_index >= 0 and _current_weapon_index<_weapons.size():
		_weapons[_current_weapon_index].fire()

func _next_weapon() -> void:
	_select_next_operational_weapon()
	_update_weapon_highlight()

#ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ДЛЯ ЦСУО (Централизованная система управления оружием)

func _select_next_operational_weapon() -> void:
	if _weapons.is_empty():
		_current_weapon_index = -1
		return
	
	var _start_index = _current_weapon_index
	var _count: int = _weapons.size()
	
	for i in _count:
		_current_weapon_index = (_current_weapon_index + 1) % _count
		if _weapons[_current_weapon_index].weapon_active:
			return
	
	_current_weapon_index = -1

func _get_operational_weapons_count() -> int:
	var count = 0
	for weapon: Weapon in _weapons:
		if weapon.weapon_active:
			count += 1
	return count

func _get_current_weapon() -> Weapon:
	if _current_weapon_index >= 0 and _current_weapon_index<_weapons.size():
		return _weapons[_current_weapon_index]
	return null

func _update_weapon_highlight() -> void:
	var arc_hexes: Array[Vector2i] = []
	
	var current_weapon = _get_current_weapon()
	if current_weapon:
		arc_hexes = current_weapon.get_arc_hexes()
	HexGridClass.highlight(arc_hexes, Color.GREEN, false, true)
