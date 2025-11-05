extends Ship


@export_group("Visuals")
@export_group("Movement")
@export_group("Weapons")

var delay = 0.01

func _ready():
	name_in_game = "Bot " + str(ship_id)

func take_turn():
	ships_array = ShipsManager.get_alive()
	update_acceleration(MaxAcceleration)
	var best_dir = 0
	var best_dist = INF
	var safe_velocity = 4
	
	var target = find_target(ships_array)
	
	for dir_index in range(6):
		var dir_vec = Utils.convert_direction(dir_index, "index", "vector")
		var test_pos = axial_position + dir_vec
		var dist = Utils.axial_distance(target.axial_position - test_pos)
		if dist < best_dist:
			best_dist = dist
			best_dir = dir_index
	while Acceleration > 0:
		
		if best_dir != dir:
			turn_right()
		elif Utils.axial_distance(ResultVelocity + facing) < safe_velocity:
			accelerate()
		else:
			update_acceleration(-1)
		await get_tree().create_timer(delay).timeout
	
	
	await get_tree().process_frame
	await start_shooting_phase()
	await get_tree().create_timer(delay).timeout
	fire()
	
	end_turn()

















