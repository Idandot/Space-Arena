class_name VerticalLabel
extends Control

@export var text: String = "":
	set(value):
		text = value
		_notify_size_changed()

@export var font_size: int = 16:
	set(value):
		font_size = value
		_notify_size_changed()

@export var font_color: Color = Color.WHITE:
	set(value):
		font_color = value
		queue_redraw()

@export var flip: bool = false:
	set(value):
		flip = value
		_notify_size_changed()


func _notify_size_changed() -> void:
	queue_redraw()
	# Уведомляем родительский контейнер о необходимости пересчитать layout
	if get_parent() is Container:
		get_parent().queue_sort()


func _get_minimum_size() -> Vector2:
	if text.is_empty():
		return Vector2.ZERO

	var font := ThemeDB.fallback_font
	var string_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)

	# После поворота на 90° ширина и высота меняются местами
	return Vector2(string_size.y, string_size.x)


func _draw() -> void:
	if text.is_empty():
		return

	var font := ThemeDB.fallback_font
	var string_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)

	var center := size / 2.0

	var angle := -PI / 2.0
	if flip:
		angle = PI / 2.0

	var offset := Vector2(-string_size.x / 2.0, string_size.y / 2.0)

	draw_set_transform(center, angle, Vector2.ONE)
	draw_string(font, offset, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, font_color)
