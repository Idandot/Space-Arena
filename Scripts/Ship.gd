extends Node2D
class_name Ship

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
var Facing = Vector2i(0,1)
var points = []
var AXIAL_DIR = [
	Vector2i(0,-1),
	Vector2i(1,0),
	Vector2i(1,1),
	Vector2i(0,1),
	Vector2i(-1,0),
	Vector2i(-1,-1),
]
var dir = 0
var InitialDir = 0
var hex_grid: Node2D
var self_id

@onready var colPoly = $Area2D/CollisionPolygon2D
@onready var poly = $Area2D/Polygon2D
@onready var area = $Area2D
@onready var Ships = get_parent()
@onready var Root = get_parent().get_parent()

signal turn_ended

func _ready():
	update_acceleration(MaxAcceleration)

func take_turn():
	pass

func turn_right():
	if update_acceleration(-1):
		dir = (dir+1)%6
		area.rotation = dir*deg_to_rad(60)
		Facing = AXIAL_DIR[dir]
	else:
		print("Insufficient Acceleration Capacity")

func turn_left():
	if update_acceleration(-1):
		dir = (dir-1)%6
		area.rotation = dir*deg_to_rad(60)
		Facing = AXIAL_DIR[dir]
	else:
		print("Insufficient Acceleration Capacity")

func update_rotation():
	area.rotation = dir*deg_to_rad(60)
	Facing = AXIAL_DIR[dir]

func accelerate():
	if update_acceleration(-1):
		NewVelocity += Facing
	else:
		print("Insufficient Acceleration Capacity")

func brake():
	if update_acceleration(-2):
		NewVelocity -= Facing
	else:
		print("Insufficient Acceleration Capacity")

func end_turn():
	ResultVelocity = PreviousVelocity + NewVelocity
	PreviousVelocity = ResultVelocity
	update_ship_position()
	NewVelocity = Vector2i.ZERO
	ResultVelocity = Vector2i.ZERO
	update_acceleration(MaxAcceleration)
	InitialDir = dir
	queue_redraw()
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
			PreviousVelocity = Vector2i.ZERO
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







