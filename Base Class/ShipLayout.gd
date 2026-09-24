extends Node
class_name ShipLayout

@export var ship_controller: Controller
@export var modules: Dictionary[Vector2i, Module]
var parent: Actor

var WCS: WeaponControlSystem = WeaponControlSystem.new()

func collect_actions() -> Array[Action]:
	var actions: Array[Action] = []
	for module in modules.values():
		actions.append_array(module.get_available_actions())
	
	var owc = WCS._get_operational_weapons_count()
	if owc > 0:
		actions.append(Action.new("fire_current_weapon", WCS.fire_current_weapon, Enums.game_states.ACTION, "fire"))
		
		if owc > 1:
			actions.append(Action.new("next_weapon", WCS.next_weapon, Enums.game_states.ACTION, "next_weapon"))
	
	return actions

func _ready() -> void:
	parent = self.get_parent()
	ship_controller = _find_controller()
	TurnManager.turn_started.connect(_on_action_phase_turn_started)
	
	WCS.setup(get_weapons())

func _find_controller() -> Controller:
	var controllers = get_modules_by_tag(Enums.module_tags.CONTROLLER)
	if controllers.size() != 1:
		push_warning("There must be 1 Controller at ship")
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
	
	WCS.update_weapon_highlight()
