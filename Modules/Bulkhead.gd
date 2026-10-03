extends Module
class_name Bulkhead

func get_available_actions() -> Array[Action]:
	return []

func _ready() -> void:
	module_name = "Bulkhead"
	module_acronym = "B"
	description = "Module that just tanks damage"
	_max_module_integrity = 15
	_module_integrity = 15
