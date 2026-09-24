extends RefCounted
class_name WeaponControlSystem

var weapons: Array[Weapon] = []
var _current_weapon_index: int = -1

func setup(new_weapons: Array[Weapon]) -> void:
	weapons = new_weapons
	_current_weapon_index = -1
	select_next_operational_weapon()

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

func update_weapon_highlight() -> void:
	var arc_hexes: Array[Vector2i] = []
	
	var current_weapon = get_current_weapon()
	if current_weapon:
		arc_hexes = current_weapon.get_arc_hexes()
	HexGridClass.highlight(arc_hexes, Color.GREEN, false, true)

func select_next_operational_weapon() -> void:
	if weapons.is_empty():
		_current_weapon_index = -1
		return
	
	var _start_index = _current_weapon_index
	var _count: int = weapons.size()
	
	for i in _count:
		_current_weapon_index = (_current_weapon_index + 1) % _count
		if weapons[_current_weapon_index].weapon_active:
			return
	
	_current_weapon_index = -1

func _get_operational_weapons_count() -> int:
	var count = 0
	for weapon: Weapon in weapons:
		if weapon.weapon_active:
			count += 1
	return count
