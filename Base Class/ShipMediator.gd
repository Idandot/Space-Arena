extends Node
class_name ActorMediator

signal physics_started(to: Vector2i)
func call_physics_started(to: Vector2i):
	physics_started.emit(to)

signal physics_finished()
func call_physics_finished():
	physics_finished.emit()
