extends KinematicBody2D

class_name Platform

const tilesets = [{
	# Down
	"left": preload("res://assets/Down/Plattform/platformIndustrial1.png"),
	"middle": preload("res://assets/Down/Plattform/platformIndustrial2.png"),
	"right": preload("res://assets/Down/Plattform/platformIndustrial3.png"),
	"tile_size": Vector2(140, 140)
}, {
	# Middle
	"left": preload("res://assets/Middle/Plattform/platform1.png"),
	"middle": preload("res://assets/Middle/Plattform/platform2.png"),
	"right": preload("res://assets/Middle/Plattform/platform3.png"),
	"tile_size": Vector2(70, 30),
}, {
	# Up
	"left": preload("res://assets/Up/Plattform/left.png"),
	"middle": preload("res://assets/Up/Plattform/middle.png"),
	"right": preload("res://assets/Up/Plattform/right.png"),
	"tile_size": Vector2(42, 36),
}]

var velocity = Vector2(0, 0)
var size = Vector2(0, 0)
var tile_count: int
var tile_scale: float
var y: float

var ExplodedScn = preload("res://scenes/exploded.tscn")

func _ready() -> void:
	$shape.shape = $shape.shape.duplicate()
	y = position.y

func _physics_process(delta) -> void:
	move_and_slide(velocity)
	handle_push_player()
	position.y = y

func set_size(calced: Dictionary) -> void:
	size = calced["size"]
	tile_scale = calced["tile_scale"]
	tile_count = calced["tile_count"]
	
	var texture = create_texture()
	var rectangle = $shape.shape as RectangleShape2D
	rectangle.extents = size / 2
	$sprite.texture = texture
	$sprite.scale = Vector2(tile_scale, tile_scale)

static func calc(new_size: Vector2) -> Dictionary:
	var tileset = get_tileset()
	var tile_size = tileset["tile_size"]
	
	var tile_scale = new_size.y / tile_size.y
	var scaled_tile_size = tile_scale * tile_size
	var tile_count = ceil(new_size.x / scaled_tile_size.x)
	if tile_count < 2:
		tile_count = 2
	var size = Vector2(tile_count, 1) * scaled_tile_size
	return {
		"tile_scale": tile_scale,
		"tile_count": tile_count,
		"size": size,
	}

static func get_tileset() -> Dictionary:
	return tilesets[Globals.level]

func create_texture() -> Texture:
	var tileset = get_tileset()
	var texture = ImageTexture.new()
	var left_texture = tileset["left"]
	var middle_texture = tileset["middle"]
	var right_texture = tileset["right"]
	var tile_size = tileset["tile_size"]
	
	var image = Image.new()
	var size = Vector2(tile_count, 1) * tile_size
	image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	
	var offset_add = Vector2(tile_size.x, 0)
	var offset = Vector2(0, 0)
	
	blit_image(image, left_texture, offset)
	offset += offset_add
	for i in range(tile_count - 2):
		blit_image(image, middle_texture, offset)
		offset += offset_add
	blit_image(image, right_texture, offset)
	offset += offset_add
	
	texture.create_from_image(image)
	return texture

func blit_image(dest: Image, src: StreamTexture, offset: Vector2) -> void:
	var src_image = src.get_data()
	var src_size = src.get_size()
	var src_rect = Rect2(Vector2(0, 0), src_size)
	dest.blit_rect(src_image, src_rect, offset)

func set_velocity(vel: Vector2) -> void:
	velocity = vel

func get_rect() -> Rect2:
	var rect = Rect2(position - size / 2, size)
	return rect

func handle_push_player() -> void:
	var count = get_slide_count()
	for i in range(count):
		var collision = get_slide_collision(0)
		var collider = collision.collider
		if collider is Player:
			collider.get_pushed(velocity)

func explode() -> Node2D:
	var exploded = ExplodedScn.instance()
	var rect = Rect2(position - size / 2, size)
	exploded.create(rect, $sprite.texture, 10, Vector2(tile_scale, tile_scale))
	queue_free()
	return exploded
