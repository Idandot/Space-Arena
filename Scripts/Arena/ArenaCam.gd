class_name ArenaCamera
extends Camera2D


@export var max_zoom = 10.0
@export var min_zoom = 0.1
@export var margin = 1.1

func zoom_to_fit(target_rect: Rect2):
	var screen_size := get_viewport_rect().size
	var target_size : Vector2 = target_rect.size * margin
	
	if target_size.x <= 0 or target_size.y <= 0:
		push_warning("Invalid rect size, zoom_to_fit aborted")
		return
	
	var target_ratio = target_size.x / target_size.y
	var viewport_ratio = screen_size.x / screen_size.y
	
	var required_zoom: float
	
	if target_ratio > viewport_ratio:
		required_zoom = screen_size.x / target_size.x
	else:
		required_zoom = screen_size.y / target_size.y
	
	required_zoom = clamp(required_zoom, min_zoom, max_zoom)
	
	zoom = required_zoom * Vector2.ONE
	global_position = target_rect.get_center()
