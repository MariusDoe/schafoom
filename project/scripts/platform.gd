extends Node2D

class_name Platform

func set_size(size: Vector2) -> void:
	var rectangle = $body/shape.shape as RectangleShape2D
	rectangle.extents = size / 2
	$sprite.region_rect = Rect2(Vector2(0, 0), size)
