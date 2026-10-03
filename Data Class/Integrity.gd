extends Resource
class_name Integrity

@export var maximum: int = 0
@export var current: int = 0

func _init(new_current: int, new_max: int) -> void:
	current = new_current
	maximum = new_max

func get_text() -> String:
	return "%d/%d" % [current, maximum]
