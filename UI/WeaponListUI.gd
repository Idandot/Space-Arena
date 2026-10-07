extends VBoxContainer
class_name WeaponListUI

@export var weapon_slot_scene: PackedScene
@export var slot_container: VBoxContainer
@export var max_weapons: int = 3

var _current_system: WeaponControlSystem
var _slot_pool: Array[WeaponSlotUI] = []

func _ready() -> void:
	TurnManager.turn_started.connect(_on_turn_started)
	_init_pool()

func _init_pool() -> void:
	for i in max_weapons:
		var slot: WeaponSlotUI = weapon_slot_scene.instantiate()
		slot_container.add_child(slot)
		slot.visible = false
		_slot_pool.append(slot)

func _on_turn_started(actor: Actor, phase: Enums.game_states) -> void:
	if phase != Enums.game_states.ACTION:
		_hide_all_slots()
		return
	
	_unbind_system()
	
	var system = actor.find_child("WeaponControlSystem", true, false)
	if system and system is WeaponControlSystem:
		_bind_system(system)
	else:
		_hide_all_slots()

func _bind_system(system: WeaponControlSystem) -> void:
	_current_system = system
	_current_system.weapon_state_changed.connect(_refresh_slots)
	
	while _slot_pool.size() < _current_system.weapons.size():
		var slot: WeaponSlotUI = weapon_slot_scene.instantiate()
		slot_container.add_child(slot)
		_slot_pool.append(slot)
	
	_refresh_slots()

func _unbind_system() -> void:
	if _current_system:
		if _current_system.weapon_state_changed.is_connected(_refresh_slots):
			_current_system.weapon_state_changed.disconnect(_refresh_slots)
	_current_system = null

func _refresh_slots() -> void:
	if !_current_system:
		_hide_all_slots()
		return
	
	var _current_weapon = _current_system.get_current_weapon()
	
	for i in _slot_pool.size():
		if i < _current_system.weapons.size():
			var weapon = _current_system.weapons[i]
			var is_current = _current_system.get_current_weapon() == weapon
			_slot_pool[i].bind(weapon, is_current)
			_slot_pool[i].visible = true
		else:
			_slot_pool[i].visible = false

func _hide_all_slots() -> void:
	for slot in _slot_pool:
		slot.visible = false
