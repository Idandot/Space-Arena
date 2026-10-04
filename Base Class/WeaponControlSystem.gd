extends Node
class_name WeaponControlSystem

var weapons: Array[Weapon] = []
var _current_weapon_index: int = -1

@onready var _ship_layout: ShipLayout = self.get_parent()
var _actor: Actor

func _ready() -> void:
	_ship_layout.ship_layout_setup_ended.connect(setup)
	_actor = _ship_layout.get_parent()
	_actor.turn_started.connect(_on_turn_started)
	TurnManager.round_started.connect(_on_round_started)

func setup() -> void:
	_ship_layout.highlight_changed.connect(update_weapon_highlight)
	_ship_layout.action_providers.append(self)
	
	weapons = _ship_layout.get_weapons()
	_current_weapon_index = -1
	select_next_operational_weapon()

func provide_actions() -> Array[Action]:
	var actions: Array[Action]
	var owc = _get_operational_weapons_count()
	if owc > 0:
		actions.append(Action.new("fire_current_weapon", fire_current_weapon, Enums.game_states.ACTION, "fire"))
		
		if owc > 1:
			actions.append(Action.new("next_weapon", next_weapon, Enums.game_states.ACTION, "next_weapon"))
	
	actions.append(Action.new("next_target", next_target, Enums.game_states.ACTION, "next_target"))
	
	return actions

func get_current_weapon() -> Weapon:
	if _current_weapon_index >= 0 and _current_weapon_index < weapons.size():
		return weapons[_current_weapon_index]
	return null

func fire_current_weapon() -> void:
	if _current_weapon_index >= 0 and _current_weapon_index<weapons.size():
		weapons[_current_weapon_index].fire()

func next_weapon() -> void:
	select_next_operational_weapon()
	update_weapon_highlight()

func next_target() -> void:
	var current_weapon = get_current_weapon()
	if current_weapon == null:
		return
	current_weapon.next_target()

func update_weapon_highlight() -> void:
	var arc_hexes: Array[Vector2i] = []
	
	var current_weapon = get_current_weapon()
	if current_weapon:
		arc_hexes = current_weapon.get_arc_hexes()
	HexGridClass.highlight(arc_hexes, Color.GREEN, false, true)

func select_next_operational_weapon() -> void:
	if weapons.is_empty():
		_current_weapon_index = -1
		GameEvents.toggle_target.emit(false)
		GameEvents.active_weapon_changed.emit(null)
		return
	
	var _start_index = _current_weapon_index
	var _count: int = weapons.size()
	
	for i in _count:
		_current_weapon_index = (_current_weapon_index + 1) % _count
		if weapons[_current_weapon_index].weapon_active:
			weapons[_current_weapon_index].next_target()
			GameEvents.active_weapon_changed.emit(weapons[_current_weapon_index])
			return
	
	_current_weapon_index = -1
	GameEvents.toggle_target.emit(false)
	GameEvents.active_weapon_changed.emit(null)

func _get_operational_weapons_count() -> int:
	var count = 0
	for weapon: Weapon in weapons:
		if weapon.weapon_active:
			count += 1
	return count

func _on_turn_started(_actor_emitter, phase: Enums.game_states):
	if phase != Enums.game_states.ACTION:
		return
	next_weapon()

func _on_round_started(_round: int) -> void:
	GameEvents.toggle_target.emit(false)
	return
