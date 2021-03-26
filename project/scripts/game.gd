extends Node2D

var platform_height = 40
var wall_height = 50

var WallScn = preload("res://scenes/wall.tscn")
var PlatformScn = preload("res://scenes/platform.tscn")

var top_wall: Wall
var bot_wall: Wall

func _ready():
	$camera.make_current()
	spawn_walls()

func spawn_platform(pos: Vector2, width: float) -> Platform:
	var platform = PlatformScn.instance()
	platform.set_size(Vector2(width, platform_height))
	platform.position = pos
	$camera.add_child(platform)
	return platform

func spawn_wall(y: float) -> Wall:
	var wall = WallScn.instance()
	var width = get_screen_size().x
	wall.set_size(Vector2(width, wall_height))
	wall.position = Vector2(0, y)
	$camera.add_child(wall)
	return wall
	
func get_screen_size() -> Vector2:
	var viewport = get_viewport()
	var rect = viewport.get_visible_rect().size * $camera.zoom
	return rect

func spawn_walls() -> void:
	var height = get_screen_size().y
	top_wall = spawn_wall(-height / 2)
	bot_wall = spawn_wall(+height / 2)
