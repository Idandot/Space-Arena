extends Content

@export var label_theme: Theme

var _actor: Actor
var labels: Dictionary[String, Label] = {}
var _health_component: HealthComponent

func setup(actor: Actor):
	if actor == null:
		return
	_clear()
	_actor = actor
	
	add_list_label("/DESCRIPTION/", [_actor.description])
	
	_health_component = _actor.find_child("HealthComponent") as HealthComponent
	if _health_component != null:
		var ss: Dictionary[String, int] = _health_component.starting_structure
		var cs = _health_component.structure
		var armor_text: Array[String]
		
		for location in ss.keys():
			armor_text.append("%s: %d/%d" % [location, cs[location], ss[location]])
		
		add_list_label("/ARMOR/", armor_text)
		
		_health_component.structure_changed.connect(_update_armor)
	
	var ship_layout: ShipLayout = _actor.find_child("ShipLayout") as ShipLayout
	if ship_layout == null:
		return
	var modules: Dictionary[Vector2i, Module] = ship_layout.modules
	var module_names: Array[String] = []
	for module: Module in modules.values():
		module_names.append(module.module_name)
	
	add_list_label("/COMPONENTS/", module_names)
	
	var weapons: Array[Weapon] = ship_layout.get_weapons()
	var weapon_names: Array[String]
	for weapon in weapons:
		weapon_names.append(weapon.module_name)
	
	add_list_label("/WEAPONS/", weapon_names)

func add_list_label(header: String, text: Array[String] = []):
	var label = Label.new()
	add_child(label)
	labels[header] = label
	
	label.theme = label_theme
	label.paragraph_separator = "\n"
	
	label.text = header
	for line in text:
		label.text += "\n" + line


func _update_label_text(label: String, header: String, text: Array[String] = []):
	labels[label].text = header
	for line in text:
		labels[label].text += "\n" + line

func _clear():
	for label: Label in labels.values():
		label.queue_free()
	labels.clear()

func _update_armor():
	var ss: Dictionary[String, int] = _health_component.starting_structure
	var cs = _health_component.structure
	var armor_text: Array[String]
	
	for location in ss.keys():
		armor_text.append("%s: %d/%d" % [location, cs[location], ss[location]])
	
	_update_label_text("/ARMOR/", "/ARMOR/", armor_text)
