extends Node2D
class_name Ship

@export var name_in_game = "Unnamed Ship"
@export var speed = 1
@export var shipLength = 50
@export var shipWidth = 30
@export var shipColor = Color(1,0.2,0.8)
@export var MaxAcceleration = 3
@export var Acceleration = MaxAcceleration
var axial_position = Vector2i(0,0)
var PreviousVelocity = Vector2i(0,0)
var NewVelocity = Vector2i(0,0)
var ResultVelocity = Vector2i(0,0)
var facing = Vector2i(0,-1)
var points = []
var AXIAL_DIR = [
	Vector2i(0,-1), #up
	Vector2i(1,0), #right up
	Vector2i(1,1), #right down
	Vector2i(0,1), #down
	Vector2i(-1,0), #left down
	Vector2i(-1,-1), #left up
]

#temporary direct enegry weapon characteristics
@export var weapon_stats = {
	"min_range": 0,
	"effective_range": 1,
	"max_range": 2,
	"arc_degrees": 120,
}
var is_weapon_active = false

var dir = 0
var InitialDir = 0
var hex_grid: Node2D
var self_id
var mass = 100
var restoration_coefficient = 0.5
var energy_to_HP = 1


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
		area.rotation = dir*deg_to_rad(60)
		facing = AXIAL_DIR[dir]
	else:
		print("Insufficient Acceleration Capacity")

func turn_left():
	if update_acceleration(-1):
		dir = (dir-1)%6
		area.rotation = dir*deg_to_rad(60)
		facing = AXIAL_DIR[dir]
	else:
		print("Insufficient Acceleration Capacity")

func update_rotation():
	area.rotation = dir*deg_to_rad(60)
	facing = AXIAL_DIR[dir]

func accelerate():
	if update_acceleration(-1):
		update_velocity(facing)
	else:
		print("Insufficient Acceleration Capacity")

func brake():
	if update_acceleration(-2):
		update_velocity(-facing)
	else:
		print("Insufficient Acceleration Capacity")

func start_shooting_phase():
	PreviousVelocity = ResultVelocity
	update_ship_position()
	NewVelocity = Vector2i.ZERO
	update_acceleration(MaxAcceleration)
	InitialDir = dir
	queue_redraw()
	
	is_weapon_active = true
	Root.turn_label.text = self.name_in_game + "'s shooting phase"
	emit_signal("request_highlight", self)

func end_turn():
	emit_signal("turn_ended")

func update_ship_position():
	var res_vel_ax = ResultVelocity
	var new_pos_ax = axial_position
	var path = decompose_vector(new_pos_ax, new_pos_ax + res_vel_ax)
	for step in path:
		await get_tree().process_frame
		var next_pos_ax = new_pos_ax + step
		var next_pos_of = Root.axial_to_offset(next_pos_ax)
		if next_pos_of.x != clamp(next_pos_of.x, 0, hex_grid.gridSizeOX - 1) \
		or next_pos_of.y != clamp(next_pos_of.y, 0, hex_grid.gridSizeOY - 1):
			print("pushed in the wall")
			update_velocity(Vector2i.ZERO, true)
			take_damage(Root.axial_distance(res_vel_ax))
			break
		else:
			new_pos_ax = next_pos_ax
	axial_position = new_pos_ax
	var world_pos = Root.axial_to_world(new_pos_ax, false)
	self.position = world_pos

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
	var NewVelW = Root.axial_to_world(NewVelocity, true)
	var PrevVelW = Root.axial_to_world(PreviousVelocity, true)
	var ResVelW = Root.axial_to_world(PreviousVelocity + NewVelocity, true)
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
	print(self.name, " had taken ", amount," damage")
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
	print("no valid targets")
	return null

func fire():
	if is_weapon_active:
		var target = find_target(ships_array)
		if target != null:
			target.take_damage(10)
			is_weapon_active = false
	else:
		print("weapon isn't active")

func is_in_shooting_arc(ax_target_pos):
	var direction: Vector2 = (Root.axial_to_world(ax_target_pos - axial_position, true)).normalized()
	var angle_to_target = rad_to_deg(direction.angle())
	var angle_diff = abs(Root.angle_difference(area.rotation, angle_to_target))
	
	return angle_diff <= weapon_stats.arc_degrees/2
	
	

























