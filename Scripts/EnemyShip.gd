extends Ship

var player: Node2D

func _ready():
	shipColor = Color(0.2,0.8,1)
	points = [Vector2(-shipWidth/2.0, shipLength/2.0), Vector2(shipWidth/2.0, shipLength/2.0), Vector2(0, -shipLength/2.0)]
	colPoly.polygon = points
	poly.polygon = points
	poly.color = shipColor
	MaxAcceleration = 3

func take_turn():
	print("Enemy takes turn")
	update_acceleration(MaxAcceleration)
	var best_dir = Facing
	var best_dist = INF
	var safe_velocity = 4
		
	for dir_index in range(6):
		var dir_vec = AXIAL_DIR[dir_index]
		var test_pos = axial_position + dir_vec
		var dist = Root.axial_distance(player.axial_position - test_pos)
		if dist < best_dist:
			best_dist = dist
			best_dir = dir_index
	while Acceleration > 0:
		if best_dir != dir:
			print(dir, "/", best_dir)
			turn_right()
		elif Root.axial_distance(NewVelocity + PreviousVelocity + AXIAL_DIR[dir]) < safe_velocity:
			print("accelerated")
			accelerate()
		else:
			update_acceleration(-1)
			print("skipped")
	end_turn()














