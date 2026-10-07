extends Node
class_name ShipLayout

signal ship_layout_setup_ended
signal highlight_changed

var ship_controller: Controller
@export var modules: Dictionary[Vector2i, Module]
var parent: Actor
var action_providers: Array[Node] = []

func collect_actions() -> Array[Action]:
	var actions: Array[Action] = []
	
	for module in modules.values():
		actions.append_array(module.get_available_actions())
	
	for provider in action_providers:
		actions.append_array(provider.provide_actions())
	
	return actions

func _ready() -> void:
	parent = self.get_parent()
	parent.setup_started.connect(_setup)

func _setup(config: ActorConfig) -> void:
	_build_from_config(config)
	ship_controller = _find_controller()
	TurnManager.turn_started.connect(_on_action_phase_turn_started)
	
	ship_layout_setup_ended.emit()

func _find_controller() -> Controller:
	var controllers = get_modules_by_tag(Enums.module_tags.CONTROLLER)
	if controllers.size() != 1:
		push_warning("There must be 1 Controller at ship")
	return controllers[0]

func get_module_or_null(position: Vector2i) -> Module:
	if modules.has(position):
		return modules[position]
	return null

func _build_from_config(config: ActorConfig) -> void:
	modules.clear()
	if config.modules == null:
		push_warning("ShipLayout: config is not provided")
		return
	
	var type_counts: Dictionary[StringName, int] = {}
	
	for placement in config.modules:
		if modules.has(placement.position):
			push_warning("ShipLayout: %s is already taken"% placement.position)
			continue
		
		var module_config = placement.config
		var module_name: String
		if module_config != null:
			module_name = module_config.get("config_name")
		else:
			module_name = placement.type
		
		if not type_counts.has(module_name):
			type_counts[module_name] = 0
		type_counts[module_name] += 1
		
		var instance_i: int = type_counts[module_name]
		
		var module = ModuleFactory.create(parent, placement.type, placement.config)
		if module == null:
			continue
		
		module.instance_index = instance_i
		module.grid_position = placement.position
		module.ship_layout = self
		add_child(module)
		modules[placement.position] = module
	
	return

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
		
		return
	if _actor != parent:
		return
	
	await get_tree().process_frame
	
	highlight_changed.emit()

func get_grid_rect(only_count_active: bool = true) -> Rect2i:
	if modules.is_empty():
		return Rect2i()
	
	var min_pos: Vector2i = modules.keys()[0]
	var max_pos: Vector2i = modules.keys()[0]
	
	for pos in modules.keys():
		if !modules[pos]._active and only_count_active:
			continue
		min_pos.x = min(min_pos.x, pos.x)
		min_pos.y = min(min_pos.y, pos.y)
		max_pos.x = max(max_pos.x, pos.x)
		max_pos.y = max(max_pos.y, pos.y)
	
	var size: Vector2i = max_pos - min_pos + Vector2i.ONE
	return Rect2i(min_pos, size)

func get_total_inner_structure() -> Integrity:
	var integrity: Integrity = Integrity.new(0, 0)
	for module: Module in modules.values():
		var module_integrity: Integrity = module.get_integrity()
		integrity.maximum += module_integrity.maximum
		if module_integrity.current > 0:
			integrity.current += module_integrity.current
	return integrity
