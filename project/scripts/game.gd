extends Node2D

var platform_height = 40
var background_move_factor = 0.5
var dash_distance = 400
var dash_potato_count = 5
var potato_probability = 0.2
var platform_spawn_distance = 200

var wall_height: float
var platform_min_distance: Vector2

var PotatoScn = preload("res://scenes/Potato.tscn")
var WallScn = preload("res://scenes/wall.tscn")
var PlatformScn = preload("res://scenes/platform.tscn")
var PlayerScn = preload("res://scenes/player.tscn")
var RobotScn = preload("res://scenes/robot_physics.tscn")

var walls = [{
	# Down
	"top": preload("res://assets/Middle/Ground/Ground.png"),
	"bot": preload("res://assets/Down/Ground/Ground.png"),
	"height": 144
}, {
	# Middle
	"top": preload("res://assets/Up/Ground/Ground.png"),
	"bot": preload("res://assets/Middle/Ground/Ground.png"),
	"height": 170
}, {
	# Up
	"bot": preload("res://assets/Up/Ground/Ground.png"),
	"height": 187
}]

var backgrounds = [{
	"path": preload("res://scenes/Background_Down.tscn")
}, {
	"path": preload("res://scenes/Background_Middle.tscn")
}, {
	"path": preload("res://scenes/Background_UP.tscn")
}]

var top_wall: Wall
var bot_wall: Wall
var player: Player
var robot: Robot
var platforms = []
var background: Node2D

func _ready() -> void:
	randomize()
	$center.position = get_screen_size() / 2
	spawn_walls()
	spawn_background()
	player = spawn_player()
	robot = spawn_robot()
	platform_min_distance = player.get_size()

func _physics_process(delta) -> void:
	set_platform_velocities()
	set_player_apparent_velocity()
	spawn_platforms(delta)
	remove_platforms()
	move_background(delta)
	move_walls(delta)
	check_player_position()

func spawn_platform(settings: Dictionary) -> Platform:
	var position = settings["position"]
	var calced = settings["calced"]
	var platform = PlatformScn.instance()
	platform.set_size(calced)
	platform.position = position
	$center.add_child(platform)
	spawn_potatoes(platform)
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
		var texture = walls["top"]
		top_wall.set_texture(texture)
	if "bot" in walls:
		bot_wall = spawn_wall(+height / 2 - wall_height / 2)
		var texture = walls["bot"]
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
	var t = Globals.time
	var velocity = 40 * pow(t, 0.5) + 100
	return Vector2(-velocity, 0)

func set_platform_velocities() -> void:
	var velocity = get_current_velocity()
	for platform in platforms:
		platform.set_velocity(velocity)

func set_player_apparent_velocity() -> void:
	var velocity = get_current_velocity()
	player.apparent_velocity = -velocity

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

func is_platform_settings_ok(settings: Dictionary) -> bool:
	var pos = settings["position"]
	var size = settings["calced"]["size"]
	var rect = Rect2(pos - size / 2, size)
	return is_platform_rect_ok(rect)

func create_platform_settings() -> Dictionary:
	var screen_size = get_screen_size()
	var width = get_platform_width()
	var size = Vector2(width, platform_height)
	var calced = Platform.calc(size)
	var calced_size = calced["size"]
	var spread = (screen_size.y - platform_height) / 2 - wall_height
	var spread_top = spread - platform_min_distance.y
	var spread_bot = spread
	var y = rand_range(-spread_top, spread_bot)
	var x = (screen_size.x + calced_size.x) / 2
	var pos = Vector2(x, y)
	return {
		"position": pos,
		"calced": calced
	}

func try_spawn_platform() -> void:
	for try in range(5):
		var settings = create_platform_settings()
		if not is_platform_settings_ok(settings):
			continue
		var platform = spawn_platform(settings)
		platforms.push_back(platform)
		return

var platform_spawn_acc = 0.0

func spawn_platforms(delta: float) -> void:
	var velocity = -get_current_velocity().x
	platform_spawn_acc += delta * velocity
	while platform_spawn_acc > platform_spawn_distance:
		try_spawn_platform()
		platform_spawn_acc -= platform_spawn_distance

func remove_platforms() -> void:
	var left_border = -get_screen_size().x / 2
	for i in range(platforms.size() - 1, -1, -1):
		var platform = platforms[i]
		var width = platform.get_rect().size.x
		if platform.position.x + width / 2 < left_border:
			platforms.remove(i)
			platform.queue_free()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("jump"):
			player.jump_trigger()
		if event.is_action_released("jump"):
			player.jump_release()
		if event.is_action_pressed("dash_down"):
			try_dash_down()
		if event.is_action_pressed("dash_up"):
			try_dash_up()

func get_background() -> Dictionary:
	return backgrounds[Globals.level]

func spawn_background() -> void:
	var background_settings = get_background()
	var scene = background_settings["path"]
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

func get_new_level(direction: int) -> int:
	var new_level = Globals.level
	match direction:
		Player.Direction.UP:
			new_level += 1
		Player.Direction.DOWN:
			new_level -= 1
	return new_level

func switch_level(direction: int) -> void:
	var new_level = get_new_level(direction)
	Globals.dash(new_level)

func _on_done_dashing() -> void:
	switch_level(player.dash_direction)

func spawn_potato(platform: Platform) -> Potato:
	var potato = PotatoScn.instance()
	platform.add_child(potato)
	potato.connect("eaten_potato", self, "_on_eaten_potato")
	return potato

func spawn_potatoes(platform: Platform) -> void:
	if randf() >= potato_probability:
		return
	var potato = spawn_potato(platform)
	var potato_size = potato.get_size()
	var platform_width = platform.get_rect().size.x
	var spread = (platform_width - potato_size.x) / 2
	var offset_x = rand_range(-spread, spread)
	var offset_y = (platform_height + potato_size.y) / 2
	var offset = Vector2(offset_x, -offset_y)
	potato.position = offset

func _on_eaten_potato() -> void:
	Globals.potato_count += 1

func try_dash_down() -> void:
	try_dash(Player.Direction.DOWN)

func try_dash_up() -> void:
	try_dash(Player.Direction.UP)

func get_distance(direction: int) -> float:
	var screen_height = get_screen_size().y
	var distance: float
	match direction:
		Player.Direction.UP:
			distance = -(-screen_height / 2 - player.position.y)
		Player.Direction.DOWN:
			distance = -screen_height / 2 - player.position.y
		_:
			return INF
	return distance

func can_dash(direction: int) -> bool:
	if not Globals.is_level_ok(get_new_level(direction)):
		return false
	
	if Globals.potato_count < dash_potato_count:
		return false
	
	var distance = get_distance(direction)
	if distance > dash_distance:
		return false
	
	return true

func try_dash(direction: int) -> void:
	if not can_dash(direction):
		return
	
	Globals.potato_count -= dash_potato_count
	player.dash(direction)

func spawn_robot() -> Robot:
	var robot = RobotScn.instance()
	var pos_x = - get_screen_size().x / 2 + robot.get_size().x
	var pos_y = 0
	robot.position = Vector2(pos_x, pos_y)
	robot.player = player
	robot.connect("destroy", self, "_on_destroy")
	$center.add_child(robot)
	return robot

func check_player_position() -> void:
	if player.position.x < robot.position.x - robot.get_size().x / 2:
		Globals.die()
