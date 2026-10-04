extends Module
class_name Weapon

@export var weapon_stats: WeaponConfig
var hex_rigidbody: HexRigidbody
var weapon_active: bool = true
var targets: Array[Actor] = []
var _current_target_index: int = 0

#ПУБЛИЧНЫЕ МЕТОДЫ

func setup(new_weapon_stats) -> void:
	weapon_stats = new_weapon_stats
	hex_rigidbody = parent.find_child("HexRigidbody")
	module_name = weapon_stats.config_name
	module_acronym = weapon_stats.config_acronym
	description = weapon_stats.config_description
	_integrity = Integrity.new(weapon_stats.max_weapon_integrity, weapon_stats.max_weapon_integrity)
	TurnManager.phase_started.connect(_on_action_phase_started)

##Стреляет из оружия, если есть возможность
func fire():
	if !_active:
		GameEvents.log_request.emit(weapon_stats.config_name +" is severely damaged. Cannot fire")
		return
	if !weapon_active:
		GameEvents.log_request.emit(weapon_stats.config_name +" is already fired this turn")
		return
	
	if _current_target_index == -1:
		GameEvents.toggle_target.emit(false)
		return
	var target: Actor = targets[_current_target_index]
	target.damage_taken.emit(weapon_stats.damage, hex_rigidbody.axial_position)
	weapon_active = false

func next_target() -> void:
	if targets.is_empty():
		GameEvents.toggle_target.emit(false)
		_current_target_index = -1
		return
	
	var _start_index = _current_target_index
	var _count: int = targets.size()
	
	for i in _count:
		_current_target_index = (_current_target_index + 1) % _count
		if targets[_current_target_index].is_alive():
			GameEvents.target_change.emit(targets[_current_target_index])
			GameEvents.toggle_target.emit(true)
			return
	
	GameEvents.toggle_target.emit(false)
	_current_target_index = -1

##Возвращается доступные действия модуля
func get_available_actions() -> Array[Action]:
	return []

##Возвращает координаты гексов в арке стрельбы
func get_arc_hexes() -> Array[Vector2i]:
	if !hex_rigidbody:
		return []
	var origin = hex_rigidbody.axial_position
	var weapon_facing: HexOrientation = HexOrientation.new()
	weapon_facing.set_direction(weapon_stats.facing_offset+hex_rigidbody.facing.get_current_index())
	return AxialUtilities.hexes_in_sector(origin, weapon_facing.get_current_vector(), 
	weapon_stats.arc_degrees, weapon_stats.min_range, weapon_stats.max_range)

#ПРИВАТНЫЕ МЕТОДЫ

func _on_action_phase_started(phase: Enums.game_states):
	if phase != Enums.game_states.ACTION:
		return
	if !_active:
		return 
	weapon_active = true
	
	await get_tree().process_frame
	
	targets = find_targets()
	next_target()

func find_targets() -> Array[Actor]:
	var alive_actors = TurnManager.alive_actors
	var new_targets: Array[Actor]
	
	for actor in alive_actors:
		if actor == parent:
			continue
		if !actor.has_node("HexRigidbody"):
			continue
		var target_rigidbody: HexRigidbody = actor.find_child("HexRigidbody")
		if !_is_in_arc(target_rigidbody.axial_position):
			continue
		new_targets.append(actor)
	
	return new_targets

func _is_in_arc(target_pos: Vector2i) -> bool:
	var arc_hexes: Array[Vector2i] = get_arc_hexes()
	var result = arc_hexes.has(target_pos)
	return result

func get_stats_text() -> String:
	var stats_text := ""
	for property in weapon_stats.get_property_list():
		if !property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			continue
		if property.type != TYPE_INT:
			continue
		
		stats_text += "%s: %s\n" % [property["name"], weapon_stats.get(property["name"])]
	return stats_text
