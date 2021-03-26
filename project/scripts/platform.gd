extends KinematicBody2D

class_name Platform

var tilesets = [{
	"path": "res://tilesets/Down.tres",
	"tile_size": Vector2(140, 140)
}, {
	"path": "res://tilesets/Middle.tres",
	"tile_size": Vector2(140, 60),
}, {
	"path": "res://tilesets/Up.tres",
	"tile_size": Vector2(42, 36),
}]

var velocity = Vector2(0, 0)
var size = Vector2(0, 0)
var y: float

func _ready() -> void:
	$shape.shape = $shape.shape.duplicate()
	y = position.y

func _physics_process(delta) -> void:
	move_and_slide(velocity)
	handle_push_player()
	position.y = y

func set_size(new_size: Vector2) -> void:
	size = new_size
	var rectangle = $shape.shape as RectangleShape2D
	rectangle.extents = size / 2
	$sprite.region_rect = Rect2(Vector2(0, 0), size)

func set_velocity(vel: Vector2) -> void:
	velocity = vel

func get_rect() -> Rect2:
	var rect = Rect2(position, size)
	return rect

func handle_push_player() -> void:
	var count = get_slide_count()
	for i in range(count):
		var collision = get_slide_collision(0)
		var collider = collision.collider
		if collider is Player:
			collider.get_pushed(velocity)
