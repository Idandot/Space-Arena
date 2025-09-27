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
		update_velocity(Facing)
	else:
		print("Insufficient Acceleration Capacity")

func brake():
	if update_acceleration(-2):
		update_velocity(-Facing)
	else:
		print("Insufficient Acceleration Capacity")

func end_turn():
	PreviousVelocity = ResultVelocity
	update_ship_position()
	NewVelocity = Vector2i.ZERO
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
		var hit_target = check_ships_collision(next_pos_ax, ships_array)
		if next_pos_of.x != clamp(next_pos_of.x, 0, hex_grid.gridSizeOX - 1) \
		or next_pos_of.y != clamp(next_pos_of.y, 0, hex_grid.gridSizeOY - 1):
			print("pushed in the wall")
			collision_process(null)
			PreviousVelocity = Vector2i.ZERO
			break
		elif (hit_target != null):
			print("collided with", hit_target)
			collision_process(hit_target)
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

func check_ships_collision(self_position: Vector2i, i_ships_array: Array):
	for s in i_ships_array:
			if (self_position == s.axial_position) and (s != self):
				return s
	return null

func take_damage(amount: int):
	print(self.name, " have taken ", amount," damage")
	pass

func update_velocity(additional_velocity: Vector2i, set_to_zero:= false):
	if set_to_zero:
		NewVelocity = Vector2i.ZERO
		PreviousVelocity = Vector2i.ZERO
	NewVelocity += additional_velocity
	ResultVelocity = NewVelocity + PreviousVelocity
	pass

func collision_process(target: Node2D):
	#Проверка если цель - стена, входные данные
	var v2: Vector2
	var m2: float
	var e2: float
	var target_axial_position: Vector2
	if target == null: #стена
		v2 = Vector2.ZERO
		m2 = INF
		e2 = 0.0
		target_axial_position = axial_position + Facing
	else:
		v2 = Vector2(target.ResultVelocity)
		m2 = target.mass
		e2 = target.restoration_coefficient
		target_axial_position = target.axial_position
	var v1 = Vector2(ResultVelocity)
	var m1: float = mass
	var e1 = restoration_coefficient
	var self_axial_position: Vector2 = axial_position
	#Вспомогательные величины
	var q = 1 / (1/m1 + 1/m2) #редуцированная масса
	var e = min(e1, e2) #Общий коэффициент восстановления
	var n = (target_axial_position - self_axial_position).normalized() #направление между кораблями
	var vrel = (v1-v2).dot(n) #относительная скорость кораблей по нормальному вектору
	#результирующий импульс и скорости
	var j = - (1+e) * vrel / q #изменение импульса для каждого корабля
	var u1 = (v1 + j / m1 * n).round() #новая скорость корабля 1
	var u2 = (v2 - j / m2 * n).round() #новая скорость корабля 2
	update_velocity(u1, true)
	if u2 != Vector2.ZERO: #чтобы стену не пыталось подвинуть
		target.update_velocity(u2, true)
	#урон зависит от потери кинетической энергии
	var deltaE = (1 - e**2) * q * vrel**2 /2
	var total_damage = deltaE * energy_to_HP
	if target == null:
		var damage1 = round(total_damage)
		take_damage(damage1)
	else:
		var damage1 = round(total_damage * m2 / (m1 + m2))
		take_damage(damage1)
		var damage2 = round(total_damage * m1 / (m1 + m2))
		target.take_damage(damage2)






