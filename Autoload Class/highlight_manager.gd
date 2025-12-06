extends Node

func highlight_sector(origin: Vector2i, 
					facing: Vector2i,
					color: Color = Color.WHITE, 
					arc_degrees: float = 120, 
					from: int = 0, 
					to: int = 50):
	var hexes_in_radius = AxialUtilities.hexes_in_radius(origin, to, from)
	
	var hexes_in_sector: Array[Vector2i] = []
	for hex_pos in hexes_in_radius:
		var angle = abs(AxialUtilities.angle_between(hex_pos - origin, facing))
		if angle <= arc_degrees / 2 or is_equal_approx(angle, arc_degrees / 2):
			hexes_in_sector.append(hex_pos)
	
	HexGridClass.highlight(hexes_in_sector, color)
