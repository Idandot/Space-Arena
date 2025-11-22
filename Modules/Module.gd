@abstract
extends Node
class_name Module

@export var ship_mediator: ShipMediator

var _component_integrity: int = 100
var _active: bool = true
var _module_name: String

@onready var parent: Actor = get_parent()


@abstract
func get_available_actions() -> Array[Action]
