extends Node
class_name ShipLayout

@export var ship_controller: Controller
@export var modules: Dictionary[Vector2i, Module]
var parent: Actor

func collect_actions() -> Array[Action]:
	var actions: Array[Action] = []
	for module in modules.values():
		actions.append_array(module.get_available_actions())
	return actions

func _ready() -> void:
	parent = self.get_parent()
	ship_controller = _find_controller()
	TurnManager.turn_started.connect(_on_action_phase_turn_started)

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
	
	#запросить Хайлайт
	var hexes_to_highlight: Array[Vector2i] = []
	for weapon in get_weapons():
		var arc = weapon.get_arc_hexes()
		for hex in arc:
			if hex not in hexes_to_highlight:
				hexes_to_highlight.append(hex)
	HexGridClass.highlight(hexes_to_highlight, Color.GREEN, false, true)
	
	pass
