extends KinematicBody2D

class_name Platform

var tilesets = [{
	# Down
	"left": "res://assets/Down/Plattform/platformIndustrial1.png",
	"middle": "res://assets/Down/Plattform/platformIndustrial2.png",
	"right": "res://assets/Down/Plattform/platformIndustrial3.png",
	"tile_size": Vector2(140, 140)
}, {
	# Middle
	"left": "res://assets/Middle/Plattform/platform1.png",
	"middle": "res://assets/Middle/Plattform/platform2.png",
	"right": "res://assets/Middle/Plattform/platform3.png",
	"tile_size": Vector2(140, 60),
}, {
	# Up
	"left": "res://assets/Up/Plattform/left.png",
	"middle": "res://assets/Up/Plattform/middle.png",
	"right": "res://assets/Up/Plattform/right.png",
	"tile_size": Vector2(42, 36),
}]

var velocity = Vector2(0, 0)
var size = Vector2(0, 0)
var tile_count: int
var tile_scale: float
var y: float

func _ready() -> void:
	$shape.shape = $shape.shape.duplicate()
	y = position.y

func _physics_process(delta) -> void:
	move_and_slide(velocity)
	handle_push_player()
	position.y = y

func set_size(new_size: Vector2) -> void:
	size = calc_size(new_size)
	var texture = create_texture()
	
	var rectangle = $shape.shape as RectangleShape2D
	rectangle.extents = size / 2
	$sprite.texture = texture
	$sprite.scale = Vector2(tile_scale, tile_scale)

func calc_size(new_size: Vector2) -> Vector2:
	var tileset = get_tileset()
	var tile_size = tileset["tile_size"]
	
	tile_scale = new_size.y / tile_size.y
	var scaled_tile_size = tile_scale * tile_size
	tile_count = ceil(new_size.x / scaled_tile_size.x)
	if tile_count < 2:
		tile_count = 2
	var size = Vector2(tile_count, 1) * scaled_tile_size
	return size

func create_texture() -> Texture:
	var tileset = get_tileset()
	var texture = LargeTexture.new()
	var left_texture = load(tileset["left"])
	var middle_texture = load(tileset["middle"])
	var right_texture = load(tileset["right"])
	var tile_size = tileset["tile_size"]
	texture.set_size(Vector2(tile_count, 1) * tile_size)
	
	var offset_add = Vector2(tile_size.x, 0)
	var offset = Vector2(0, 0)
	texture.add_piece(offset, left_texture)
	offset += offset_add
	for i in range(tile_count - 2):
		texture.add_piece(offset, middle_texture)
		offset += offset_add
	texture.add_piece(offset, right_texture)
	offset += offset_add
	
	texture
	return texture

func get_tileset() -> Dictionary:
	return tilesets[0]

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
