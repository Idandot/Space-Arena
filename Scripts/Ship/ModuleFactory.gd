extends RefCounted
class_name ModuleFactory

const REGISTRY: Dictionary = {
	&"weapon": preload("res://Scripts/Ship/Modules/Weapon/Weapon.tscn"),
	&"controller": preload("res://Scripts/Ship/Modules/PlayerController/PlayerController.tscn"),
	&"engine": preload("res://Scripts/Ship/Modules/Engine/Engine.tscn"),
	&"bulkhead": preload("res://Scripts/Ship/Modules/Bulkhead/Bulkhead.tscn")
}

static func create(actor: Actor, type: StringName, config: Resource) -> Module:
	if not REGISTRY.has(type):
		push_error("ModuleFactory: Unknown type: %s"%type)
		return null
	
	var scene: PackedScene = REGISTRY[type]
	var module: Module = scene.instantiate()
	module.parent = actor
	module.setup(config)
	return module
