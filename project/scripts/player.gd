extends KinematicBody2D

class_name Player

var gravity = Vector2(0, 800)
var jump_velocity = Vector2(0, -1000)
var velocity_reduction_factor = 10.0
var jump_max_time = 0.25

var velocity = Vector2(0, 0)
var jump_cooldown = 0.0

var dash_duration = 1.0
var dash_time_scale = 0.5

var dash_depth = 500
var dash_down_prejump_height = 40
var dash_curve_down: Curve
var dash_curve_up: Curve

var pushed: bool

var apparent_velocity: Vector2

enum Direction {
	UP,
	DOWN,
}

var dashing = false
var dash_direction: int
var dash_time: float
var dash_start_y: float

signal done_dashing
signal destroy(thing)

func _ready() -> void:
	create_dash_curves()

func _physics_process(delta: float):
	if dashing:
		perform_dash(delta)
		return
	apply_jump_velocity(delta)
	add_gravity(delta)
	move_and_slide(velocity)
	reset_velocity_on_collision()
	pushed = false

func jump_trigger() -> void:
	if not can_jump():
		return
	velocity = jump_velocity
	jump_cooldown = jump_max_time
	var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(music_player)
	var stream = preload("res://sfx/Player/bodyimpact_jack_01.wav")
	var volume = -5
	music_player.stream = stream
	music_player.volume_db = volume
	music_player.play()

func jump_release() -> void:
	jump_cooldown = 0.0

func can_jump() -> bool:
	if pushed:
		return true
	return is_on_wall()

func add_gravity(delta: float) -> void:
	velocity += gravity * delta

func apply_jump_velocity(delta: float) -> void:
	jump_cooldown -= delta
	if jump_cooldown > 0.0:
		return
	if velocity.y < 0.0:
		velocity.y *= exp(-velocity_reduction_factor * delta)

func get_pushed(velocity: Vector2) -> void:
	move_and_slide(velocity)
	pushed = true

func reset_velocity_on_collision() -> void:
	if is_on_wall():
		velocity.y = 0

func get_size() -> Vector2:
	return $shape.shape.extents * 2

func create_dash_curves():
	var tangent = 3 * dash_depth
	
	dash_curve_up = Curve.new()
	dash_curve_up.add_point(Vector2(0, -1), 0, 0)
	dash_curve_up.add_point(Vector2(1, -dash_depth), -tangent, -tangent)
	
	dash_curve_down = Curve.new()
	dash_curve_down.add_point(Vector2(0, -1), 0, 0)
	dash_curve_down.add_point(Vector2(0.35, -dash_down_prejump_height), 0, 0)
	dash_curve_down.add_point(Vector2(1, dash_depth), tangent, tangent)

func get_dash_curve() -> Curve:
	match dash_direction:
		Direction.UP:
			return dash_curve_up
		Direction.DOWN:
			return dash_curve_down
	return null

func dash(direction: int) -> void:
	dash_direction = direction
	dash_start_y = position.y
	dash_time = 0.0
	dashing = true
	Engine.time_scale = dash_time_scale

func perform_dash(delta: float) -> void:
	if dash_time >= dash_duration:
		dashing = false
		Engine.time_scale = 1.0
		emit_signal("done_dashing")
		return
	var curve = get_dash_curve()
	var t = dash_time / dash_duration
	var old_height = position.y
	var new_height = dash_start_y + curve.interpolate(t)
	var distance = apparent_velocity.x * delta
	var offset = new_height - old_height
	var tangent = offset / distance
	var angle = atan(tangent)
	$sprite.rotation = angle
	var collision = move_and_collide(Vector2(0, offset))
	if collision:
		var collider = collision.collider
		emit_signal("destroy", collider)
	dash_time += delta
