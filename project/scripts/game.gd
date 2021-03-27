extends Node2D

var platform_height = 40
var wall_height: float
var background_move_factor = 0.5

var platform_min_distance: Vector2

var WallScn = preload("res://scenes/wall.tscn")
var PlatformScn = preload("res://scenes/platform.tscn")
var PlayerScn = preload("res://scenes/player.tscn")

var walls = [{
	# Down
	"top": "res://assets/Middle/Ground/Ground.png",
	"bot": "res://assets/Down/Ground/Ground.png",
	"height": 144
}, {
	# Middle
	"top": "res://assets/Up/Ground/Ground.png",
	"bot": "res://assets/Middle/Ground/Ground.png",
	"height": 170
}, {
	# Up
	"bot": "res://assets/Up/Ground/Ground.png",
	"height": 187
}]

var backgrounds = [{
	"path": "res://scenes/Background_Down.tscn"
}, {
	"path": "res://scenes/Background_Middle.tscn"
}, {
	"path": "res://scenes/Background_UP.tscn"
}]

var top_wall: Wall
var bot_wall: Wall
var player: Player
var platforms = []
var background: Node2D

func _ready() -> void:
	randomize()
	$center.position = get_screen_size() / 2
	spawn_walls()
	spawn_background()
	player = spawn_player()
	platform_min_distance = player.get_size()

func _physics_process(delta) -> void:
	set_platform_velocities(delta)
	spawn_platforms()
	move_background(delta)
	move_walls(delta)

func spawn_platform(pos: Vector2, width: float) -> Platform:
	var platform = PlatformScn.instance()
	platform.set_size(Vector2(width, platform_height))
	platform.position = pos
	$center.add_child(platform)
	return platform

func spawn_wall(y: float) -> Wall:
	var wall = WallScn.instance()
	var width = get_screen_size().x
	wall.set_size(Vector2(width, wall_height))
	wall.position = Vector2(0, y)
	$center.add_child(wall)
	return wall

func get_screen_size() -> Vector2:
	var viewport = get_viewport()
	var rect = viewport.get_visible_rect().size
	return rect

func spawn_walls() -> void:
	var walls = get_walls()
	wall_height = walls["height"]
	var height = get_screen_size().y
	if "top" in walls:
		top_wall = spawn_wall(-height / 2 + wall_height / 2)
		var texture = load(walls["top"])
		top_wall.set_texture(texture)
	if "bot" in walls:
		bot_wall = spawn_wall(+height / 2 - wall_height / 2)
		var texture = load(walls["bot"])
		bot_wall.set_texture(texture)

func get_walls() -> Dictionary:
	return walls[Globals.level]

func spawn_player() -> Player:
	var player = PlayerScn.instance()
	player.position = Vector2(0, 0)
	player.connect("destroy", self, "_on_destroy")
	player.connect("done_dashing", self, "_on_done_dashing")
	$center.add_child(player)
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
		platform_rect = platform_rect.grow_individual(
				platform_min_distance.x, platform_min_distance.y,
				platform_min_distance.x, platform_min_distance.y)
		if rect.intersects(platform_rect):
			return false
	return true

func create_new_platform_rect() -> Rect2:
	var screen_size = get_screen_size()
	var width = get_platform_width()
	var spread = (screen_size.y - platform_height) / 2 - wall_height
	var spread_top = spread - platform_min_distance.y
	var spread_bot = spread
	var y = rand_range(-spread_top, spread_bot)
	var x = (screen_size.x + width) / 2
	var pos = Vector2(x, y)
	var size = Vector2(width, platform_height)
	var rect = Rect2(pos, size)
	return rect

func adjust_platform_rect(rect: Rect2) -> Rect2:
	var old_size = rect.size
	var temp_platform = PlatformScn.instance()
	rect.size = temp_platform.calc_size(rect.size)
	temp_platform.queue_free()
	rect.position.x += (old_size.x - rect.size) / 2
	return rect

func create_new_platform() -> void:
	for try in range(5):
		var rect = create_new_platform_rect()
		var test_rect = adjust_platform_rect(rect)
		if not is_platform_rect_ok(test_rect):
			continue
		var platform = spawn_platform(test_rect.position, rect.size.x)
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
		if event.is_action_pressed("dash_down"):
			player.dash_down()
		if event.is_action_pressed("dash_up"):
			player.dash_up()

func get_background() -> Dictionary:
	return backgrounds[Globals.level]

func spawn_background() -> void:
	var background_settings = get_background()
	var scene = load(background_settings["path"])
	background = scene.instance()
	add_child(background)

func move_background(delta: float) -> void:
	var parallax = background.get_node("ParallaxBackground") as ParallaxBackground
	var velocity = get_current_velocity()
	var offset = velocity.x * delta * background_move_factor
	parallax.scroll_offset.x += offset

func move_walls(delta: float) -> void:
	var velocity = get_current_velocity()
	var offset = velocity.x * delta
	if top_wall:
		top_wall.move(offset)
	if bot_wall:
		bot_wall.move(offset)

func explode_wall(wall: Wall) -> void:
	var exploded = wall.explode()
	$center.add_child(exploded)

func explode_platform(platform: Platform) -> void:
	platforms.erase(platform)
	var exploded = platform.explode()
	$center.add_child(exploded)

func _on_destroy(thing) -> void:
	if thing is Wall:
		if top_wall == thing:
			explode_wall(top_wall)
			top_wall = null
		if bot_wall == thing:
			explode_wall(bot_wall)
			bot_wall = null
	if thing is Platform:
		explode_platform(thing)

func switch_level(direction: int) -> void:
	var new_level = Globals.level
	match direction:
		Player.Direction.UP:
			new_level += 1
		Player.Direction.DOWN:
			new_level -= 1
	
	Globals.level = new_level
	get_tree().change_scene("res://scenes/game.tscn")

func _on_done_dashing() -> void:
	switch_level(player.dash_direction)
