@abstract
extends Module
class_name Controller

var plan: Array[Callable]
@warning_ignore("unused_private_class_variable")
var _actions: Dictionary[String, Action]

func _ready() -> void:
	parent.turn_started.connect(_take_control)

@abstract
func _take_control(_actor: Actor)
