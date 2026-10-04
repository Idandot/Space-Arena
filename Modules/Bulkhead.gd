extends Module
class_name Bulkhead

func get_available_actions() -> Array[Action]:
	return []

func setup(_config: Resource) -> void:
	module_name = "Bulkhead"
	module_acronym = "B"
	description = "Module that just tanks damage"
	_integrity = Integrity.new(15, 15)
