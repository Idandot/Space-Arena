extends Content

const SECTION_DESCRIPTION = "DESCRIPTION"
const SECTION_STATS = "STATS"
const SECTION_ARMOR = "ARMOR"
const SECTION_MODULES = "MODULES"
const SECTION_WEAPONS = "WEAPONS"

@export var label_theme: Theme

var _actor: Actor
var _health_component: HealthComponent
var _labels: Dictionary[StringName, Label] = {}

func setup(actor: Actor) -> void:
	if not is_instance_valid(actor):
		return
	
	_clear()
	_actor = actor
	
	_add_section(SECTION_DESCRIPTION, [_actor.description])
	_setup_stats()
	_setup_armor()
	_setup_ship_modules()

#НАСТРОЙКА СЕКЦИЙ

func _setup_stats() -> void:
	_actor.initiative_changed.connect(_update_initiative)
	var stats_text: Array[String] = ["initiative: %.2f" % _actor.get_initiative()]
	_add_section(SECTION_STATS, stats_text)

func _setup_armor() -> void:
	_health_component = _actor.get_node_or_null("HealthComponent") as HealthComponent
	if not _health_component:
		return
	
	_health_component.structure_changed.connect(_update_armor)
	
	var armor_text: Array[String] = _build_armor_text()
	_add_section(SECTION_ARMOR, armor_text)

func _setup_ship_modules() -> void:
	var ship_layout: ShipLayout = _actor.get_node_or_null("ShipLayout") as ShipLayout
	if not ship_layout:
		return
	
	var modules_text: Array[String] = []
	for module: Module in ship_layout.modules.values():
		modules_text.append(module.module_name)
	_add_section(SECTION_MODULES, modules_text)

#РАБОТА С UI

func _add_section(section_key: StringName, lines: Array[String] = []) -> void:
	var label := Label.new()
	add_child(label)
	_labels[section_key] = label
	
	label.theme = label_theme
	label.text = _format_section_text(section_key, lines)

func _update_section(section_key: StringName, lines: Array[String] = []) -> void:
	if not _labels.has(section_key):
		push_warning("UI Section '%s' not found. Was it initialized?" % section_key)
		return
	
	_labels[section_key].text = _format_section_text(section_key, lines)

func _format_section_text(header: String, lines: Array[String]) -> String:
	if lines.is_empty():
		return header
	return "%s\n%s" % [header, "\n".join(lines)]

func _build_armor_text() -> Array[String]:
	var armor_text: Array[String] = []
	var starting: Dictionary[String, int] = _health_component.starting_structure
	var current: Dictionary[String, int] = _health_component.structure
	
	for location: String in starting.keys():
		var current_hp: int = current.get(location, 0)
		var max_hp: int = starting[location]
		armor_text.append("%s: %d/%d" % [location, current_hp, max_hp])
	
	return armor_text

#CALLABLE ДЛЯ СИГНАЛОВ

func _update_initiative():
	var stats_text: Array[String] = ["initiative: %.2f" % _actor.get_initiative()]
	_update_section(SECTION_STATS, stats_text)

func _update_armor() -> void:
	if not _health_component:
		return
	
	_update_section(SECTION_ARMOR, _build_armor_text())

#ЧИСТКА И ПАМЯТЬ

func _clear():
	_disconnect_signals()
	
	for label: Label in _labels.values():
		if is_instance_valid(label):
			label.queue_free()
	_labels.clear()
	
	_actor = null
	_health_component = null

func _disconnect_signals() -> void:
	if is_instance_valid(_actor) and _actor.initiative_changed.is_connected(_update_initiative):
		_actor.initiative_changed.disconnect(_update_initiative)
	
	if is_instance_valid(_health_component) and _health_component.structure_changed.is_connected(_update_armor):
		_health_component.structure_changed.disconnect(_update_armor)
