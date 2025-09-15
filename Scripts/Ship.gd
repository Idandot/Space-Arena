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

@onready var colPoly = $Area2D/CollisionPolygon2D
@onready var poly = $Area2D/Polygon2D

signal end_movement(ship)

func setup():
	points = [Vector2(-shipWidth/2, shipLength/2), Vector2(shipWidth/2, shipLength/2), Vector2(0, -shipLength/2)]
	colPoly.polygon = points
	poly.polygon = points
	poly.color = shipColor

func turn_right():
	if Acceleration > 0:
		Acceleration -= 1
		dir = (dir+1)%6
		self.rotation = dir*deg_to_rad(60)
		Facing = AXIAL_DIR[dir]
		print("Facing: ", Facing)
		print("Acceleration left: ", Acceleration, "/", MaxAcceleration)
	else:
		print("Insufficient Acceleration Capacity")

func turn_left():
	if Acceleration > 0:
		Acceleration -= 1
		dir = (dir-1)%6
		self.rotation = dir*deg_to_rad(60)
		Facing = AXIAL_DIR[dir]
		print("Facing: ", Facing)
		print("Acceleration left: ", Acceleration, "/", MaxAcceleration)
	else:
		print("Insufficient Acceleration Capacity")

func update_rotation():
	self.rotation = dir*deg_to_rad(60)
	Facing = AXIAL_DIR[dir]
	print("Facing: ", Facing)

func accelerate():
	if Acceleration > 0:
		Acceleration -= 1
		NewVelocity += Facing
		print("Velocity: ", NewVelocity)
		print("Acceleration left: ", Acceleration, "/", MaxAcceleration)
	else:
		print("Insufficient Acceleration Capacity")

func brake():
	if Acceleration > 1:
		Acceleration -= 2
		NewVelocity -= Facing
		print("Velocity: ", NewVelocity)
		print("Acceleration left: ", Acceleration, "/", MaxAcceleration)
	else:
		print("Insufficient Acceleration Capacity")

func _unhandled_key_input(event):
	if event.is_action_pressed("turn_left"):
		turn_left()
	elif event.is_action_pressed("turn_right"):
		turn_right()
	elif event.is_action_pressed("accelerate"):
		accelerate()
	elif event.is_action_pressed("brake"):
		brake()
	elif event.is_action_pressed("end_movement"):
		Position += NewVelocity
		emit_signal("end_movement", self)
		PreviousVelocity = NewVelocity
		NewVelocity = Vector2i.ZERO
		Acceleration = MaxAcceleration
		InitialDir = dir
		print("Turn End")
	elif event.is_action_pressed("Reset"):
		NewVelocity = Vector2i.ZERO
		Acceleration = MaxAcceleration
		dir = InitialDir
		update_rotation()
		print("Turn Reset")

