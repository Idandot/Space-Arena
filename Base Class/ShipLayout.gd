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
