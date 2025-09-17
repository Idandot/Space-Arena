extends Node2D

var ship

@onready var HexGrid = get_parent()

func _ready():
	
	pass # Replace with function body.

func _on_hex_grid_child_entered_tree(node):
	if node.name == "Ship":
		ship = node
		ship.connect("action", action_pressed)

func action_pressed():
	queue_redraw()

func _draw():
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var PositionW = ship.position
	#Это конечные координаты векторов
	var NewPosVelW = HexGrid.axial_to_world(ship.NewVelocity + ship.Position, false)
	var PrevPosVelW = HexGrid.axial_to_world(ship.PreviousVelocity + ship.Position, false)
	var ResPosVelW = HexGrid.axial_to_world(ship.PreviousVelocity + ship.NewVelocity + ship.Position, false)
	print(ship.NewVelocity, ship.PreviousVelocity, ship.ResultVelocity)
	print(NewPosVelW, PrevPosVelW, ResPosVelW)
	draw_arrow(PositionW, ResPosVelW, Color(1,1,1), 5)
	draw_arrow(PositionW, NewPosVelW, Color(0,1,0))
	draw_arrow(PositionW, PrevPosVelW, Color(0,0,1))
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













