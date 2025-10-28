extends Node2D

@export var base_color = Color(1, 1, 1, 0.5)
@export var effective_color = Color(0, 1, 0, 0.5)
@export var penalty_color = Color(1, 1, 0, 0.5)
@export var super_penalty_color = Color(1, 0.5, 0, 0.5)
@export var red = Color(1, 0.5, 0, 0.5)

@onready var Root = get_parent().get_parent()
@onready var HexGrid = Root.find_child("HexGrid")
@onready var Ships = Root.find_child("Ships")

func clear_highlight():
	for hex in HexGrid.get_children():
		hex.deselected()

func highlight_shooting_range(ship: Node2D):
	
	clear_highlight()
	var ship_pos: Vector2i = ship.axial_position
	var ship_hex = HexGrid.get_hex(ship_pos)
	var ship_facing: Vector2i = ship.facing
	
	#temporary weapon stats
	var weapon_stats = ship.weapon_stats
	
	var hexes_in_range = HexGrid.get_hexes_in_range(ship_pos, weapon_stats.max_range)
	
	for hex_data in hexes_in_range:
		var hex = hex_data.hex
		var distance = hex_data.distance
		if ship.is_in_shooting_arc(hex_data.axial_position):
			var color = color_to_set(weapon_stats, distance)
			if color:
				hex.selected(color)

func color_to_set(weapon_stats: Dictionary, distance: int):
	if distance <= weapon_stats.min_range:
		return super_penalty_color
	elif distance > weapon_stats.effective_range:
		return penalty_color
	else:
		return effective_color

func _ready():
	for ship in Root.ships_array:
		ship.connect("request_highlight", self.highlight_shooting_range)





















