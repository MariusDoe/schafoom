extends StaticBody2D

class_name Wall

var size: Vector2

var ExplodedScn = preload("res://scenes/exploded.tscn")

func set_size(new_size: Vector2) -> void:
	size = new_size
	var rectangle = $shape.shape as RectangleShape2D
	rectangle.extents = size / 2
	$sprite.region_rect = Rect2(Vector2(0, 0), size)

func move(offset: float) -> void:
	$sprite.region_rect.position.x -= offset

func set_texture(texture: Texture) -> void:
	$sprite.texture = texture

func explode() -> Node2D:
	var exploded = ExplodedScn.instance()
	var rect = Rect2(position - size / 2, size)
	exploded.create(rect, $sprite.texture.duplicate(true), 50)
	queue_free()
	return exploded
