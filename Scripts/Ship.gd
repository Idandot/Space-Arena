extends Node2D
class_name Ship

@export_group("Visuals")
@export var name_in_game = "Unnamed Ship"
@export var speed = 1
@export var shipLength = 25
@export var shipWidth = 20
@export var shipColor = Color(1,0.2,0.8)
var points = []

@export_group("Movement")
@export var MaxAcceleration = 3
@export var Acceleration = MaxAcceleration
var turn_cost = 1
var accelerate_cost = 1
var brake_cost = 2
var axial_position = Vector2i(0,0)
var offset_position = Vector2i(0,0)
var PreviousVelocity = Vector2i(0,0)
var NewVelocity = Vector2i(0,0)
var ResultVelocity = Vector2i(0,0)

var initial_facing: String
var facing: HexDirection

@export_group("Weapons")
@export var weapon_stats = {
	"damage": 10,
	"min_range": 0,
	"effective_range": 2,
	"max_range": 4,
	"arc_degrees": 120,
	"apex_offset": 1,
	"facing_offset": 1,
}
var is_weapon_active = false

@export_group("Structure")
@export var starting_structure = {
	"nose": 30,
	"left wing": 40,
	"right wing": 40,
	"aft": 20,
	"inner structure": 50,
}
@onready var structure: Dictionary = starting_structure.duplicate(true)

var ship_id
var team_id

var mass = 100
var is_player = false
var Utils = SpaceArenaUtilities
var BEM = BattleEventManager

@onready var colPoly = $Area2D/CollisionPolygon2D
@onready var poly = $Area2D/Polygon2D
@onready var area = $Area2D
@onready var Ships = get_parent()
@onready var Root = get_parent().get_parent()
@onready var hex_grid = Root.find_child("HexGrid", false)
var ships_array: Array

signal turn_ended
signal request_highlight(ship)
signal destroyed(ship)

func init_from_data(data):
	if !data.has("spawnpointOf"):
		BEM.battle_log(["ERROR: no spawnpoint in ", data], "Critical")
		print("ERROR: no spawnpoint in ", data)
		return
	axial_position = Utils.offset_to_axial(data.spawnpointOf)
	self.position = Utils.axial_to_world(axial_position)
	
	
	if !data.has("initial_facing"):
		BEM.battle_log(["ERROR: no initial facing in ", data], "Critical")
		print("ERROR: no initial facing in ", data)
		return
	if area == null:
		BEM.battle_log(["ERROR: no area2D found ", data], "Critical")
		print("ERROR: no area2D found ", data)
		return
	facing = HexDirection.new(data.initial_facing)
	set_area_rotation()
	initial_facing = facing.get_name()
	
	if !data.has("max_acceleration"):
		BEM.battle_log(["ERROR: no max acceleration in ", data], "Critical")
		print("ERROR: no max acceleration in ", data)
		return
	MaxAcceleration = data.max_acceleration
	
	if !data.has("color"):
		BEM.battle_log(["ERROR: no color in ", data], "Critical")
		print("ERROR: no color in ", data)
		return
	shipColor = data.color
	poly.color = shipColor
	
	ships_array = ShipsManager.ships
	
	#отрисовка
	points = [Vector2(-shipLength/2.0, shipWidth/2.0), 
	Vector2(-shipLength/2.0, -shipWidth/2.0), 
	Vector2(shipLength/2.0, 0)]
	colPoly.polygon = points
	poly.polygon = points
	
	if Root.debug_mode.ship_init == true:
		print("ship ", name_in_game, "created")


func take_turn():
	pass

func turn_right():
	if update_acceleration(-turn_cost):
		facing.rotate_right()
		set_area_rotation()
	else:
		BEM.battle_log(["Insufficient acceleration capacity"], "Warning")

func turn_left():
	if update_acceleration(-turn_cost):
		facing.rotate_left()
		set_area_rotation()
	else:
		BEM.battle_log(["Insufficient acceleration capacity"], "Warning")

func set_area_rotation():
	area.rotation = deg_to_rad(facing.angle)

func accelerate():
	if update_acceleration(-accelerate_cost):
		update_velocity(facing.vector)
	else:
		BEM.battle_log(["Insufficient acceleration capacity"], "Warning")

func brake():
	if update_acceleration(-brake_cost):
		update_velocity(-facing.vector)
	else:
		BEM.battle_log(["Insufficient acceleration capacity"], "Warning")

func start_shooting_phase():
	ships_array = ShipsManager.get_alive()
	PreviousVelocity = ResultVelocity
	await update_ship_position()
	NewVelocity = Vector2i.ZERO
	update_acceleration(MaxAcceleration)
	initial_facing = facing.get_name()
	queue_redraw()
	
	await get_tree().process_frame
	
	is_weapon_active = true
	Root.turn_label.text = self.name_in_game + "'s shooting phase"
	
	emit_signal("request_highlight", self)

func end_turn():
	if Root.debug_mode.ship_rotation:
		print("DEBUG INFO:")
		print("facing: ", facing.get_vector(), ", angle: ", rad_to_deg(area.rotation))
	emit_signal("turn_ended")

func update_ship_position():
	var res_vel_ax = ResultVelocity
	var new_pos_ax = axial_position
	var path = decompose_vector(new_pos_ax, new_pos_ax + res_vel_ax)
	for step in path:
		await get_tree().process_frame
		var next_pos_ax = new_pos_ax + step
		var next_pos_of = Utils.axial_to_offset(next_pos_ax)
		if next_pos_of.x != clamp(next_pos_of.x, 0, hex_grid.gridSizeOX - 1) \
		or next_pos_of.y != clamp(next_pos_of.y, 0, hex_grid.gridSizeOY - 1):
			BEM.battle_log([self.name_in_game, " pushed in the wall"])
			update_velocity(Vector2i.ZERO, true, true)
			take_damage(Utils.axial_distance(res_vel_ax), axial_position + facing.get_vector())
			break
		else:
			new_pos_ax = next_pos_ax
	axial_position = new_pos_ax
	offset_position = Utils.axial_to_offset(axial_position)
	var world_pos = Utils.axial_to_world(new_pos_ax, false)
	self.position = world_pos
	if Root.debug_mode.ship_position:
		print("DEBUG INFO:")
		print("world position: ", world_pos)
		print("axial position: ", axial_position)
		print("offset position: ", offset_position)

func decompose_vector(start_pos: Vector2i, end_pos: Vector2i) -> Array:
	#TODO: try Bresenham method
	var change_pos = end_pos - start_pos
	var path = []
	while change_pos != Vector2i.ZERO:
		var h = change_pos.x
		var k = change_pos.y
		var l = h+k
		if abs(h) >= abs(k) and abs(h) >= abs(l):
			var step = Vector2i(sign(h), 0)
			change_pos -= step
			path.append(step)
		elif abs(k) >= abs(l) and abs(k) >= abs(h):
			var step = Vector2i(0, sign(k))
			change_pos -= step
			path.append(Vector2i(step))
		else:
			var step = Vector2i(sign(l), sign(l))
			change_pos -= step
			path.append(step)
	return path

func update_acceleration(amount: int) -> bool:
	Acceleration += amount
	var is_valid = true
	if Acceleration > MaxAcceleration:
		Acceleration = MaxAcceleration
	elif Acceleration < 0:
		Acceleration -= amount
		is_valid = false
	return is_valid

func _draw():
	#Это конечные координаты векторов
	var NewVelW = Utils.axial_to_world(NewVelocity, true)
	var PrevVelW = Utils.axial_to_world(PreviousVelocity, true)
	var ResVelW = Utils.axial_to_world(PreviousVelocity + NewVelocity, true)
	draw_arrow(Vector2.ZERO, ResVelW, Color(1,1,1),2)
	draw_arrow(Vector2.ZERO, NewVelW, Color(0,1,0))
	draw_arrow(Vector2.ZERO, PrevVelW, Color(0,0,1))
	pass

func draw_arrow(from: Vector2, to: Vector2, col:= Color(1,1,1), w:=-1):
	draw_line(from, to, col, w)
	var direction = (to - from)
	if direction.length() == 0:
		return
	var normalized_direction = direction.normalized()
	var left = normalized_direction.rotated(deg_to_rad(150)) * min(12, direction.length()*0.2)
	var right = normalized_direction.rotated(deg_to_rad(-150)) * min(12, direction.length()*0.2)
	draw_line(to, to + left, col, w)
	draw_line(to, to + right, col, w)

func take_damage(amount: int, ax_attacker_pos: Vector2i):
	var location = define_arc(ax_attacker_pos)
	var excess_damage = 0
	
	structure[location] -= amount
	if structure[location] <= 0:
		excess_damage = abs(structure[location])
		structure[location] = 0
	
	structure["inner structure"] -= excess_damage
	if structure["inner structure"] <= 0:
		BEM.battle_log([name_in_game, " is destroyed"], "Critical")
		Destroy()
		return
	
	BEM.battle_log([self.name, " had taken ", 
	amount, " damage in ", location])
	
	BEM.battle_log([location, " armor left: ", 
	structure[location], "/", starting_structure[location]])
	
	if excess_damage != 0:
		BEM.battle_log(["inner structure left: ", 
		structure["inner structure"], "/", 
		starting_structure["inner structure"]], "Warning")

func Destroy(to_emit_signal:= true):
	if to_emit_signal:
		emit_signal("destroyed", self)
	
	queue_free()
	pass

func update_velocity(additional_velocity: Vector2i, reset_new:= false, reset_prev:=false):
	if reset_new:
		NewVelocity = Vector2i.ZERO
	if reset_prev:
		PreviousVelocity = Vector2i.ZERO
	NewVelocity += additional_velocity
	ResultVelocity = NewVelocity + PreviousVelocity
	queue_redraw()

func find_target(targets):
	#TODO: smart target filter
	for ship in targets:
		if !is_instance_valid(ship):
			BEM.battle_log(["ERROR: target isn't valid"], "Critical")
			return null
		if ship.is_queued_for_deletion():
			BEM.battle_log(["ERROR: target is queued for deletion"], "Critical")
			return null
		if ship.team_id != self.team_id:
			return ship
	BEM.battle_log(["ERROR: no valid targets"], "Critical")
	return null

func fire():
	if !is_weapon_active:
		return fire_fail("Weapon isn't active")
	var target = find_target(ships_array)
	if target == null:
		BEM.battle_log(["ERROR: target is NULL"], "Critical")
		return
	if !is_in_shooting_arc(target.axial_position):
		return fire_fail("Target is out of shooting arc")
	var distance_to_target = Utils.axial_distance(target.axial_position - axial_position)
	if distance_to_target > weapon_stats.max_range:
		return fire_fail("Target is out of range")
	
	target.take_damage(weapon_stats["damage"], axial_position)
	is_weapon_active = false

func fire_fail(reason):
	if is_player:
		BEM.battle_log([reason], "Warning")

func is_in_shooting_arc(ax_target_pos) -> bool:
	var weapon_facing = HexDirection.new(facing.index + weapon_stats.facing_offset)
	
	for r in range(weapon_stats.apex_offset + 1):
		if axial_position + weapon_facing.vector * r == ax_target_pos:
			return true
	
	
	var divergence_origin = axial_position + weapon_stats.apex_offset * facing.vector
	var direction: Vector2 = (Utils.axial_to_world(ax_target_pos - divergence_origin, true)).normalized()
	var angle_to_target = rad_to_deg(direction.angle())
	var angle_diff = abs(Utils.angle_difference(weapon_facing.angle, angle_to_target))
	
	return is_equal_approx(angle_diff, weapon_stats.arc_degrees/2) or angle_diff < weapon_stats.arc_degrees/2

func define_arc(ax_attacker_pos) -> String:
	var nose_arc_angle = facing.angle
	
	var direction: Vector2 = (Utils.axial_to_world(ax_attacker_pos - axial_position, true)).normalized()
	var angle_to_attacker = rad_to_deg(direction.angle())
	
	var nose_arc_diff = Utils.angle_difference(nose_arc_angle, angle_to_attacker)
	var left_wing_arc_diff = Utils.angle_difference(nose_arc_angle - 90, angle_to_attacker)
	var right_wing_arc_diff = Utils.angle_difference(nose_arc_angle + 90, angle_to_attacker)
	
	if left_wing_arc_diff <= 30:
		return "left wing"
	elif right_wing_arc_diff <= 30:
		return "right wing"
	elif nose_arc_diff <= 90:
		return "nose"
	else:
		return "aft"
















