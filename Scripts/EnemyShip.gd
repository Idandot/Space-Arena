extends Ship

var player: Node2D

func _ready():
	ships_array = Root.ships_array
	points = [Vector2(-shipLength/2.0, shipWidth/2.0), Vector2(-shipLength/2.0, -shipWidth/2.0), Vector2(shipLength/2.0, 0)]
	area.rotation = deg_to_rad(-90)
	colPoly.polygon = points
	poly.polygon = points
	poly.color = shipColor
	MaxAcceleration = 3
	name_in_game = "Enemy"

func take_turn():
	update_acceleration(MaxAcceleration)
	var best_dir = 0
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
			turn_right()
		elif Root.axial_distance(ResultVelocity + AXIAL_DIR[dir]) < safe_velocity:
			accelerate()
		else:
			update_acceleration(-1)
		await get_tree().create_timer(0.2).timeout
	
	
	await get_tree().process_frame
	await start_shooting_phase()
	await get_tree().create_timer(0.2).timeout
	fire()
	
	end_turn()













