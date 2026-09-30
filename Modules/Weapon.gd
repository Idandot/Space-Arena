extends Module
class_name Weapon

@export var weapon_stats: WeaponConfig
var hex_rigidbody: HexRigidbody
var weapon_active: bool = true

#ПУБЛИЧНЫЕ МЕТОДЫ

func setup(new_weapon_stats) -> void:
	weapon_stats = new_weapon_stats
	hex_rigidbody = parent.find_child("HexRigidbody")
	module_name = weapon_stats.config_name
	module_acronym = weapon_stats.config_acronym
	TurnManager.phase_started.connect(_on_action_phase_started)

##Стреляет из оружия, если есть возможность
func fire():
	if !weapon_active:
		GameEvents.log_request.emit(weapon_stats.name +" is already fired this turn")
		return
	
	var target: Actor = _find_target()
	if target == null:
		GameEvents.log_request.emit("No target available")
		return
	if !target.has_node("HealthComponent"):
		print("цель не может получить урон")
		return
	target.get_node("HealthComponent").take_damage_from_position(weapon_stats.damage, hex_rigidbody.axial_position)
	weapon_active = false

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
	weapon_active = true

func _find_target() -> Actor:
	var alive_actors = TurnManager.alive_actors
	var best_target: Actor = null
	
	#временный код, в будущем поиск цели будет реализован более сложно
	for actor in alive_actors:
		if actor == parent:
			continue
		if !actor.has_node("HexRigidbody"):
			continue
		var target_rigidbody: HexRigidbody = actor.find_child("HexRigidbody")
		if !_is_in_arc(target_rigidbody.axial_position):
			continue
		best_target = actor
	
	return best_target

func _is_in_arc(target_pos: Vector2i) -> bool:
	
	for hex in get_arc_hexes():
		if hex == target_pos:
			return true
	return false
