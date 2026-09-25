extends RefCounted
class_name ModuleFactory

const REGISTRY: Dictionary = {
	&"weapon": preload("res://Modules/weapon.tscn"),
	&"controller": preload("res://Modules/PlayerController.tscn"),
	&"engine": preload("res://Modules/Engine.tscn"),
	&"bulkhead": preload("res://Modules/Bulkhead.tscn")
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
