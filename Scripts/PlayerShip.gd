extends Ship

var acceleration_label: Label
var can_act = false


func _ready():
	acceleration_label = Root.acceleration_label
	points = [Vector2(-shipWidth/2.0, shipLength/2.0), Vector2(shipWidth/2.0, shipLength/2.0), Vector2(0, -shipLength/2.0)]
	colPoly.polygon = points
	poly.polygon = points
	poly.color = shipColor

func _process(delta):
	if !can_act:
		return
	if Input.is_action_just_pressed("turn_left"):
		turn_left()
	elif Input.is_action_just_pressed("turn_right"):
		turn_right()
	elif Input.is_action_just_pressed("accelerate"):
		accelerate()
	elif Input.is_action_just_pressed("brake"):
		brake()
	elif Input.is_action_just_pressed("end_movement"):
		end_turn()
		can_act = false
	elif Input.is_action_just_pressed("Reset"):
		NewVelocity = Vector2i.ZERO
		update_acceleration(MaxAcceleration)
		dir = InitialDir
		update_rotation()
		print("Turn Reset")
	queue_redraw()

func update_acceleration(amount: int) -> bool:
	var is_valid = super.update_acceleration(amount)
	acceleration_label.text = "Acceleration " + str(Acceleration) + "/" + str(MaxAcceleration)
	return is_valid

func take_turn():
	can_act = true

















