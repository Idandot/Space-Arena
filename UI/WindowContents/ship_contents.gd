extends Content

var _actor: Actor
@export var labels: Array[Label]

func setup(actor: Actor):
	if !actor:
		return
	_actor = actor
	
	add_text(0, "/DESCRIPTION/", false)
	
	add_text(0, _actor.description)
	
	add_text(1, "/COMPONENTS/", false)
	
	var ship_layout: ShipLayout = actor.find_child("ShipLayout")
	var modules: Dictionary[Vector2i, Module] = ship_layout.modules
	var module_names: Array[String] = []
	for module: Module in modules.values():
		module_names.append(module.module_name)
	
	for module_name in module_names:
		add_text(1, module_name)
	
	add_text(2, "/WEAPONS/", false)
	
	var weapons: Array[Weapon] = ship_layout.get_weapons()
	for weapon in weapons:
		add_text(2, weapon.module_name)
	
	return

func add_text(label_index: int, new_text: String, new_line: bool = true):
	var label = labels[label_index]
	if new_line:
		label.text += "\n"
	label.text += new_text
