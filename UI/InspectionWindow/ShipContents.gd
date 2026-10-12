extends Content
class_name ShipContents

#КОНСТАНТЫ
const SECTION_DESCRIPTION = "/DESCRIPTION/"
const SECTION_STATS = "/STATS/"
const SECTION_MODULE_DETAILS = "/MODULE DETAILS/"

#ЭКСПОРТЫ
@export var label_theme: Theme
@export var empty_cell_color:= Color(0.2, 0.2, 0.2, 0.5)
@export var cell_size:= Vector2(24,24)

#ССЫЛКИ НА НОДЫ
@export var ship_grid: GridContainer
@export var description_label: Label
@export var stats_label: Label
@export var module_details_label: RichTextLabel

#ЛОКАЦИИ БРОНИ
@export var location_labels: Dictionary[String, Control] = {
}

#СОСТОЯНИЕ
var _actor: Actor
var _damage_resolver: DamageResolver
var _ship_layout: ShipLayout
var _selected_module: Module
var _cells: Dictionary[Vector2i, Button] = {}

#ПУБЛИЧНЫЕ МЕТОДЫ
func setup(actor: Actor) -> void:
	if not is_instance_valid(actor):
		return
	
	_clear_state()
	_actor = actor
	
	_actor.initiative_changed.connect(_update_stats)
	
	_ship_layout = _actor.get_node_or_null("ShipLayout") as ShipLayout
	
	if _ship_layout != null:
		_damage_resolver = _ship_layout.get_node_or_null("DamageResolver") as DamageResolver
		if _damage_resolver:
			_damage_resolver.structure_changed.connect(_update_armor)
	
	_populate_ui()

func _populate_ui() -> void:
	description_label.text = "%s\n%s" % [SECTION_DESCRIPTION, _actor.description]
	
	_update_stats()
	
	_update_armor("", [])
	
	if _ship_layout:
		_build_ship_grid()
	
	_update_module_details(null)
	_connect_location_labels()

#РАБОТА С СЕТКОЙ
func _build_ship_grid() -> void:
	for child in ship_grid.get_children():
		child.queue_free()
	
	var modules: Dictionary[Vector2i, Module] = _ship_layout.modules
	if modules.is_empty():
		return
	
	var modules_rect: Rect2i = _ship_layout.get_grid_rect(false)
	var min_pos: Vector2i = modules_rect.position
	var max_pos: Vector2i = min_pos + modules_rect.size - Vector2i.ONE
	
	ship_grid.columns = modules_rect.size.x
	
	for y in range(max_pos.y, min_pos.y -1, -1):
		for x in range(min_pos.x, max_pos.x +1):
			var current_pos:= Vector2i(x, y)
			
			if modules.has(current_pos):
				ship_grid.add_child(_create_module_cell(modules[current_pos]))
			else:
				ship_grid.add_child(_create_empty_cell())

func _create_module_cell(module: Module) -> Control:
	var btn: Button = Button.new()
	btn.custom_minimum_size = cell_size
	btn.tooltip_text = module.module_name
	btn.text = module.module_acronym
	
	if _damage_resolver:
		var module_integrity = module.get_integrity()
		var hp_ratio: float = float(module_integrity.current) / float(module_integrity.maximum)
		btn.modulate = Color(1,1,1,1).lerp(Color(1, 0.2, 0.2, 1), 1.0 - hp_ratio)
	
	btn.pressed.connect(_update_module_details.bind(module))
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	_cells[module.grid_position] = btn
	return btn

func _create_empty_cell() -> Control:
	var panel := Panel.new()
	panel.custom_minimum_size = cell_size
	var style := StyleBoxFlat.new()
	style.bg_color = empty_cell_color
	panel.add_theme_stylebox_override("panel", style)
	return panel

#РАБОТА С ЛОКАЦИЯМИ

func _connect_location_labels() -> void:
	for location_name in location_labels.keys():
		var label: Control = location_labels[location_name]
		if !is_instance_valid(label):
			continue
		
		label.mouse_filter = Control.MOUSE_FILTER_STOP
		
		if label.gui_input.is_connected(_on_location_label_gui_input):
			label.gui_input.disconnect(_on_location_label_gui_input)
		
		label.gui_input.connect(_on_location_label_gui_input.bind(location_name))

func _on_location_label_gui_input(event: InputEvent, location_name: StringName) -> void:
	var mouse_event: InputEventMouseButton
	if event is InputEventMouseButton:
		mouse_event = event
	else:
		return
	if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
		_highlight_location_arc(location_name)

func _highlight_location_arc(location_name: StringName) -> void:
	HexGridClass.clear_layer(HexGridClass.highlight_layers.INSPECTION)
	
	if !_damage_resolver:
		return
	
	var arc_hexes: Array[Vector2i] = _damage_resolver.get_location_arc_hexes(location_name)
	if arc_hexes.is_empty():
		return
	
	HexGridClass.highlight_layer(
		HexGridClass.highlight_layers.INSPECTION,
		arc_hexes, Color.CYAN)

#ОБНОВЛЕНИЯ
func _update_stats():
	var total_integrity: Integrity = _ship_layout.get_total_inner_structure()
	var stats_text: Array[String] = [
		"Initiative: %.2f\n" % _actor.get_initiative(),
		"Total inner intergity: %s\n" % total_integrity.get_text()
		]
	stats_label.text = "%s\n%s" % [SECTION_STATS, "".join(stats_text)]

func _update_armor(_location: String, damaged_modules: Array[Module]) -> void:
	if not _damage_resolver:
		return
	for label in location_labels.values():
		label.text = ""
	
	var starting: Dictionary[String, int] = {}
	var current: Dictionary[String, int] = {}
	for property in _damage_resolver.starting_structure.get_property_list():
		if !property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			continue
		if property.type != TYPE_INT:
			continue
		
		starting[property.name] = _damage_resolver.starting_structure.get(property.name)
		current[property.name] = _damage_resolver.structure.get(property.name)
	
	
	for location: String in starting.keys():
		if !location_labels.has(location):
			continue
		
		var label = location_labels[location]
		if not label:
			continue
		
		var current_hp: int = current.get(location, 0)
		var max_hp: int = starting[location]
		var hp_ratio: float = float(current_hp) / max_hp
		label.text = "%s: %d/%d" % [location, current_hp, max_hp]
		label.modulate = Color(1,1,1,1).lerp(Color(1, 0.2, 0.2, 1), 1.0 - hp_ratio)
	
	for module in damaged_modules:
		var module_integrity = module.get_integrity()
		var hp_ratio: float = float(module_integrity.current) / float(module_integrity.maximum)
		var module_pos: Vector2i = module.grid_position
		_cells[module_pos].modulate = Color(1,1,1,1).lerp(Color(1, 0.2, 0.2, 1), 1.0 - hp_ratio)
	
	_update_stats()

func _update_module_details(module: Module) -> void:
	HexGridClass.clear_layer(HexGridClass.highlight_layers.INSPECTION)
	
	if not module:
		module_details_label.text = "%s\nSelect module to inspect it" % SECTION_MODULE_DETAILS
		return
	
	_selected_module = module
	var details: String = "%s\n" % module.module_name
	details += "%s\n" % module.description
	details += "Integrity: %s \n" % module.get_integrity().get_text()
	
	
	if module.has_method("get_stats_text"):
		details += module.get_stats_text()
	
	module_details_label.text = "%s\n%s" % [SECTION_MODULE_DETAILS, details]
	
	if module is Weapon:
		var weapon: Weapon = module as Weapon
		var arc_hexes: Array[Vector2i] = weapon.get_arc_hexes()
		HexGridClass.highlight_layer(HexGridClass.highlight_layers.INSPECTION,
		arc_hexes, Color.YELLOW, false, false)

#Чистка
func _clear_state() -> void:
	_disconnect_signals()
	
	for child in ship_grid.get_children():
		child.queue_free()
	
	_actor = null
	_ship_layout = null
	_damage_resolver = null
	_selected_module = null
	
	HexGridClass.clear_layer(HexGridClass.highlight_layers.INSPECTION)

func _disconnect_signals() -> void:
	if is_instance_valid(_actor) and _actor.initiative_changed.is_connected(_update_stats):
		_actor.initiative_changed.disconnect(_update_stats)
	
	if is_instance_valid(_damage_resolver) and _damage_resolver.structure_changed.is_connected(_update_armor):
		_damage_resolver.structure_changed.disconnect(_update_armor)

func _exit_tree() -> void:
	_clear_state()
