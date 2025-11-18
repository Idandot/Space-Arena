extends Node2D
class_name VectorVisualizer

@export var hex_rigidbody: HexRigidbody

var vectors: Dictionary[String, Dictionary] = {}
var vector_template: Dictionary[String, Variant] = {
	"name": "unnamed",
	"start": Vector2i.ZERO,
	"end": Vector2i.ZERO,
	"color": Color.WHITE,
	"width": 0.2,
	"jagged": false,
	"arrow": false
}

func _ready() -> void:
	if hex_rigidbody.has_signal("velocity_changed"):
		hex_rigidbody.velocity_changed.connect(_hex_rigidbody_visualization)

func _standardize_vector(vector: Dictionary[String, Variant]) -> Dictionary[String, Variant]:
	var standartized_vector: Dictionary[String, Variant] = {}
	for key in vector_template.keys():
		if !vector.has(key):
			standartized_vector[key] = vector_template[key]
			continue
		if typeof(vector[key]) != typeof(vector_template[key]):
			standartized_vector[key] = vector_template[key]
			continue
		standartized_vector[key] = vector[key]
	return standartized_vector

func add_vector(new_vector: Dictionary[String, Variant]) -> void:
	var std_vector = _standardize_vector(new_vector)
	vectors[std_vector["name"]] = std_vector

func delete_vector(vector_name: String):
	vectors.erase(vector_name)

func _draw():
	#добавить поддержку Jagged векторов в будущем для рисования не прямой, а ломаной траектории
	for vector_data in vectors.values():
		var vd = vector_data.duplicate()
		var fromW = AxialUtilities.axial_to_world(vd["start"])
		var toW = AxialUtilities.axial_to_world(vd["end"])
		if !vector_data["arrow"]:
			draw_line(fromW, toW, vd["color"], vd["width"])
		else:
			_draw_arrow(fromW, toW, vd["color"], vd["width"], vd["jagged"])
		pass

func _draw_arrow(from: Vector2, to: Vector2, col:= Color.WHITE, w:=5, jagged := false):
	if !jagged:
		draw_line(from, to, col, w)
	else:
		var axial_vector = AxialUtilities.world_to_axial(to-from)
		var axial_path = AxialUtilities.decompose_vector(axial_vector)
		var world_points = [from]
		var world_sum = Vector2.ZERO
		for vector in axial_path:
			var world_vector = AxialUtilities.axial_to_world(vector)
			world_sum += world_vector
			world_points.append(world_sum)
		draw_polyline(world_points, col, w)
	var direction = (to - from)
	if direction.length() == 0:
		return
	var normalized_direction = direction.normalized()
	var left = normalized_direction.rotated(deg_to_rad(150)) * min(12, direction.length()*0.2)
	var right = normalized_direction.rotated(deg_to_rad(-150)) * min(12, direction.length()*0.2)
	draw_line(to, to + left, col, w)
	draw_line(to, to + right, col, w)

func _update_visuals():
	queue_redraw()

func _hex_rigidbody_visualization(velocity_data: Dictionary[String, Variant]):
	
	for vector_name in vectors.keys():
		delete_vector(vector_name)
	
	add_vector({
		"name": "velocity",
		"start": Vector2i.ZERO,
		"end": velocity_data["result"],
		"color": Color.WHITE,
		"width": 5.0,
		"arrow": true,
	})
	add_vector({
		"name": "inertial_velocity",
		"start": Vector2i.ZERO,
		"end": velocity_data["previous_velocity"],
		"color": Color.BLUE,
		"width": 3.0,
		"arrow": true,
		
	})
	for impulse_name in velocity_data["impulse_dict"].keys():
		var impulse: Vector2i = velocity_data["impulse_dict"][impulse_name]
		add_vector({
			"name": "impulse_"+impulse_name,
			"start": Vector2i.ZERO,
			"end": impulse,
			"color": Color.RED,
			"width": 3.0,
			"arrow": true
		})
	for force_name in velocity_data["force_dict"].keys():
		var force: Vector2i = velocity_data["force_dict"][force_name]
		add_vector({
			"name": "force_"+force_name,
			"start": Vector2i.ZERO,
			"end": force,
			"color": Color.GREEN,
			"width": 3.0,
			"arrow": true
		})
	_update_visuals()
