extends Ship

@export_group("Visuals")
@export_group("Movement")
@export_group("Weapons")

var acceleration_label: Label
var can_move = false
var can_shoot = false


func _ready():
	is_player = true
	ships_array = Root.ships_array
	acceleration_label = Root.acceleration_label
	points = [Vector2(-shipLength/2.0, shipWidth/2.0), Vector2(-shipLength/2.0, -shipWidth/2.0), Vector2(shipLength/2.0, 0)]
	area.rotation = deg_to_rad(Utils.convert_direction(initial_direction,"name", "angle"))
	dir = Utils.convert_direction(initial_direction,"name", "index")
	initial_dir = dir
	colPoly.polygon = points
	poly.polygon = points
	poly.color = shipColor
	name_in_game = "Player"

func _process(_delta):
	if !can_move:
		pass
	elif Input.is_action_just_pressed("turn_left"):
		turn_left()
	elif Input.is_action_just_pressed("turn_right"):
		turn_right()
	elif Input.is_action_just_pressed("accelerate"):
		accelerate()
	elif Input.is_action_just_pressed("brake"):
		brake()
	elif Input.is_action_just_pressed("end_phase"):
		can_move = false
		can_shoot = true
		await get_tree().process_frame
		start_shooting_phase()
		
	elif Input.is_action_just_pressed("Reset"):
		reset()
	if !can_shoot:
		return
	elif Input.is_action_just_pressed("fire"):
		fire()
	elif Input.is_action_just_pressed("end_phase"):
		can_shoot = false
		end_turn()
		await get_tree().process_frame
	queue_redraw()

func update_acceleration(amount: int) -> bool:
	var is_valid = super.update_acceleration(amount)
	acceleration_label.text = "Acceleration " + str(Acceleration) + "/" + str(MaxAcceleration)
	return is_valid

func take_turn():
	can_move = true

func reset():
	update_velocity(Vector2i.ZERO, true)
	update_acceleration(MaxAcceleration)
	dir = initial_dir
	update_rotation()
	BEM.battle_log(["Movement reset"])










