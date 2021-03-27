extends Node2D

var platform_height = 40
var wall_height = 170

var platform_min_distance: float

var WallScn = preload("res://scenes/wall.tscn")
var PlatformScn = preload("res://scenes/platform.tscn")
var PlayerScn = preload("res://scenes/player.tscn")

var top_wall: Wall
var bot_wall: Wall
var player: Player
var platforms = []

func _ready() -> void:
	randomize()
	$camera.make_current()
	spawn_walls()
	player = spawn_player()
	platform_min_distance = player.get_size().y

func _physics_process(delta) -> void:
	set_platform_velocities(delta)
	spawn_platforms()

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
	top_wall = spawn_wall(-height / 2 + wall_height / 2)
	top_wall.set_texture(preload("res://assets/Middle/Ceiling/Ceiling.png"))
	bot_wall = spawn_wall(+height / 2 - wall_height / 2)
	bot_wall.set_texture(preload("res://assets/Middle/Ground/Ground.png"))
	

func spawn_player() -> Player:
	var player = PlayerScn.instance()
	player.position = Vector2(0, 0)
	$camera.add_child(player)
	return player

func get_current_velocity() -> Vector2:
	return Vector2(-100, 0)

func set_platform_velocities(delta: float) -> void:
	var velocity = get_current_velocity()
	for platform in platforms:
		platform.set_velocity(velocity)

func get_platform_width() -> float:
	return rand_range(100, 500)

func is_platform_rect_ok(rect: Rect2) -> bool:
	for platform in platforms:
		var platform_rect = platform.get_rect()
		platform_rect = platform_rect.grow(platform_min_distance)
		if rect.intersects(platform_rect):
			return false
	return true

func create_new_platform_rect() -> Rect2:
	var screen_size = get_screen_size()
	var width = get_platform_width()
	var spread = (screen_size.y - platform_height) / 2 - wall_height
	var spread_top = spread - platform_min_distance
	var spread_bot = spread
	var y = rand_range(-spread_top, spread_bot)
	var x = (screen_size.x + width) / 2
	var pos = Vector2(x, y)
	var size = Vector2(width, platform_height)
	
	var temp_platform = PlatformScn.instance()
	size = temp_platform.calc_size(size)
	temp_platform.queue_free()
	
	var rect = Rect2(pos, size)
	return rect

func create_new_platform() -> void:
	for try in range(5):
		var rect = create_new_platform_rect()
		if not is_platform_rect_ok(rect):
			continue
		var platform = spawn_platform(rect.position, rect.size.x)
		platforms.push_back(platform)
		return

func spawn_platforms() -> void:
	if randf() < 0.01:
		create_new_platform()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("jump"):
			player.jump_trigger()
		if event.is_action_released("jump"):
			player.jump_release()
			
func spawn_background():
	var background = preload("res://scenes/Background_Middle.tscn").instance()
	$camera.add_child(background)
