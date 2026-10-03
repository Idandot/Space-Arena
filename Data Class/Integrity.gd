extends Node
class_name Integrity

var maximum: int
var current: int

func _init(new_current: int, new_max: int) -> void:
	current = new_current
	maximum = new_max
