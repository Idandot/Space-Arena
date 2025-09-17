extends Node2D

@export var speed = 1
@export var shipLength = 50
@export var shipWidth = 30
@export var shipColor = Color(1,0.2,0.8)
@export var MaxAcceleration = 10
@export var Acceleration = MaxAcceleration
var Position = Vector2i(0,0)
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
var acceleration_label: Label

@onready var colPoly = $Area2D/CollisionPolygon2D
@onready var poly = $Area2D/Polygon2D
@onready var HexGrid = get_parent()

signal action()

func _ready():
	acceleration_label = HexGrid.AccelerationText
	points = [Vector2(-shipWidth/2.0, shipLength/2.0), Vector2(shipWidth/2.0, shipLength/2.0), Vector2(0, -shipLength/2.0)]
	colPoly.polygon = points
	poly.polygon = points
	poly.color = shipColor

func turn_right():
	if update_acceleration(-1):
		dir = (dir+1)%6
		self.rotation = dir*deg_to_rad(60)
		Facing = AXIAL_DIR[dir]
		print("Facing: ", Facing)
	else:
		print("Insufficient Acceleration Capacity")

func turn_left():
	if update_acceleration(-1):
		dir = (dir-1)%6
		self.rotation = dir*deg_to_rad(60)
		Facing = AXIAL_DIR[dir]
		print("Facing: ", Facing)
	else:
		print("Insufficient Acceleration Capacity")

func update_rotation():
	self.rotation = dir*deg_to_rad(60)
	Facing = AXIAL_DIR[dir]
	print("Facing: ", Facing)

func accelerate():
	if update_acceleration(-1):
		NewVelocity += Facing
		print("Velocity: ", NewVelocity)
	else:
		print("Insufficient Acceleration Capacity")

func brake():
	if update_acceleration(-2):
		NewVelocity -= Facing
		print("Velocity: ", NewVelocity)
	else:
		print("Insufficient Acceleration Capacity")

func _unhandled_key_input(event):
	emit_signal("action")
	if event.is_action_pressed("turn_left"):
		turn_left()
	elif event.is_action_pressed("turn_right"):
		turn_right()
	elif event.is_action_pressed("accelerate"):
		accelerate()
	elif event.is_action_pressed("brake"):
		brake()
	elif event.is_action_pressed("end_movement"):
		ResultVelocity = PreviousVelocity + NewVelocity
		PreviousVelocity = ResultVelocity
		update_ship_position()
		NewVelocity = Vector2i.ZERO
		ResultVelocity = Vector2i.ZERO
		update_acceleration(MaxAcceleration)
		InitialDir = dir
		print("Turn End")
	elif event.is_action_pressed("Reset"):
		NewVelocity = Vector2i.ZERO
		update_acceleration(MaxAcceleration)
		dir = InitialDir
		update_rotation()
		print("Turn Reset")

func update_ship_position():
	var res_vel_ax = ResultVelocity
	var new_pos_ax = Position
	var path = decompose_vector(new_pos_ax, new_pos_ax + res_vel_ax)
	for step in path:
		var next_pos_ax = new_pos_ax + step
		var next_pos_of = HexGrid.axial_to_offset(next_pos_ax)
		if next_pos_of.x != clamp(next_pos_of.x, 0, HexGrid.gridSizeOX - 1) \
		or next_pos_of.y != clamp(next_pos_of.y, 0, HexGrid.gridSizeOY - 1):
			print("pushed in the wall")
			PreviousVelocity = Vector2i.ZERO
			break
		else:
			new_pos_ax = next_pos_ax
	Position = new_pos_ax
	var world_pos = HexGrid.axial_to_world(new_pos_ax, false)
	self.position = world_pos

func decompose_vector(start_pos: Vector2i, end_pos: Vector2i) -> Array:
	var change_pos = end_pos - start_pos
	print(change_pos)
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
	print(path)
	return path

func update_acceleration(amount: int) -> bool:
	Acceleration += amount
	var is_valid = true
	if Acceleration > MaxAcceleration:
		Acceleration = MaxAcceleration
	elif Acceleration < 0:
		Acceleration -= amount
		is_valid = false
	acceleration_label.text = "Acceleration " + str(Acceleration) + "/" + str(MaxAcceleration)
	return is_valid








