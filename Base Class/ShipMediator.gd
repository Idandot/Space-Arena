extends Node
class_name ActorMediator

signal movement_ended(to: Vector2i)
func call_movement_ended(to: Vector2i):
	movement_ended.emit(to)

signal movement_animation_finished()
func call_movement_animation_finished():
	movement_animation_finished.emit()
