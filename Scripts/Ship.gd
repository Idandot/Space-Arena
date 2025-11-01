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
@export var initial_direction = "down"
var axial_position = Vector2i(0,0)
var offset_position = Vector2i(0,0)
var PreviousVelocity = Vector2i(0,0)
var NewVelocity = Vector2i(0,0)
var ResultVelocity = Vector2i(0,0)
var facing = Vector2i(0,-1)

@export_group("Weapons")
@export var weapon_stats = {
	"min_range": 0,
	"effective_range": 2,
	"max_range": 4,
	"arc_degrees": 120,
	"apex_offset": 1,
	"facing_offset": 1,
}
var is_weapon_active = false

var dir: int = 0
var initial_dir = 0
var hex_grid: Node2D
var self_id
var mass = 100
var Utils = SpaceArenaUtilities

@onready var colPoly = $Area2D/CollisionPolygon2D
@onready var poly = $Area2D/Polygon2D
@onready var area = $Area2D
@onready var Ships = get_parent()
@onready var Root = get_parent().get_parent()
var ships_array: Array

signal turn_ended
signal request_highlight(ship)

func take_turn():
	pass

func turn_right():
	if update_acceleration(-1):
		dir = (dir+1)%6
		change_rotation(dir)
		
	else:
		print("FUTURE INDICATION: ","Insufficient Acceleration Capacity")

func turn_left():
	if update_acceleration(-1):
		dir = (dir-1)%6
		print(dir)
		change_rotation(dir)
	else:
		print("FUTURE INDICATION: ","Insufficient Acceleration Capacity")

func update_rotation():
	change_rotation(dir)

func change_rotation(to_dir: int):
	facing = Utils.convert_direction(to_dir,"index", "vector")
	area.rotation = deg_to_rad(Utils.convert_direction(to_dir,"index", "angle"))

func accelerate():
	if update_acceleration(-1):
		update_velocity(facing)
	else:
		print("FUTURE INDICATION: ","Insufficient Acceleration Capacity")

func brake():
	if update_acceleration(-2):
		update_velocity(-facing)
	else:
		print("FUTURE INDICATION: ","Insufficient Acceleration Capacity")

func start_shooting_phase():
	PreviousVelocity = ResultVelocity
	await update_ship_position()
	NewVelocity = Vector2i.ZERO
	update_acceleration(MaxAcceleration)
	initial_dir = dir
	queue_redraw()
	
	await get_tree().process_frame
	
	is_weapon_active = true
	Root.turn_label.text = self.name_in_game + "'s shooting phase"
	
	emit_signal("request_highlight", self)

func end_turn():
	if Root.debug_mode.ship_rotation:
		print("DEBUG INFO:")
		print("facing: ", facing, ", angle: ", rad_to_deg(area.rotation))
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
			print("FUTURE INDICATION: ","pushed in the wall")
			update_velocity(Vector2i.ZERO, true)
			take_damage(Utils.axial_distance(res_vel_ax))
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

func check_ships_collision(self_position: Vector2i, i_ships_array: Array):
	for s in i_ships_array:
			if (self_position == s.axial_position) and (s != self):
				return s
	return null

func take_damage(amount: int):
	print("FUTURE INDICATION: ", self.name, " had taken ", amount," damage")
	pass

func update_velocity(additional_velocity: Vector2i, set_to_zero:= false):
	if set_to_zero:
		NewVelocity = Vector2i.ZERO
		PreviousVelocity = Vector2i.ZERO
	NewVelocity += additional_velocity
	ResultVelocity = NewVelocity + PreviousVelocity
	queue_redraw()

func find_target(targets):
	for ship in targets:
		if ship.name_in_game != self.name_in_game:
			return ship
	print("FUTURE INDICATION: ","no valid targets")
	return null

func fire():
	if !is_weapon_active:
		print("FUTURE INDICATION: ","weapon isn't active")
		return
	var target = find_target(ships_array)
	if target == null:
		print("FUTURE INDICATION: ","no target")
		return
	if !is_in_shooting_arc(target.axial_position):
		print("FUTURE INDICATION: ","Target isn't in shooting arc")
		return
	var distance_to_target = Utils.axial_distance(target.axial_position - axial_position)
	if distance_to_target > weapon_stats.max_range:
		print("FUTURE INDICATION: ","Target isn't in range")
		return
	
	target.take_damage(10)
	is_weapon_active = false


func is_in_shooting_arc(ax_target_pos) -> bool:
	
	var weapon_facing_vector = Utils.convert_direction(dir + weapon_stats.facing_offset, "index", "vector")
	
	for r in range(weapon_stats.apex_offset + 1):
		if axial_position + weapon_facing_vector * r == ax_target_pos:
			return true
	
	
	var divergence_origin = axial_position + weapon_stats.apex_offset * facing
	var direction: Vector2 = (Utils.axial_to_world(ax_target_pos - divergence_origin, true)).normalized()
	var angle_to_target = rad_to_deg(direction.angle())
	var weapon_facing_angle = Utils.convert_direction(dir + weapon_stats.facing_offset, "index", "angle")
	print(weapon_facing_angle, angle_to_target)
	var angle_diff = abs(Utils.angle_difference(weapon_facing_angle, angle_to_target))
	
	return is_equal_approx(angle_diff, weapon_stats.arc_degrees/2) or angle_diff < weapon_stats.arc_degrees/2

func define_arc():
	
	pass
















