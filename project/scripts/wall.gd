extends StaticBody2D

class_name Wall

func set_size(size: Vector2) -> void:
	var rectangle = $shape.shape as RectangleShape2D
	rectangle.extents = size / 2
	$sprite.region_rect = Rect2(Vector2(0, 0), size)

func move(offset: float) -> void:
	$sprite.region_rect.position.x -= offset

func set_texture(texture: Texture) -> void:
	$sprite.texture = texture
