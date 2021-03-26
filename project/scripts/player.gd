extends KinematicBody2D

class_name Player

var gravity = Vector2(0, 600)
var jump_velocity = Vector2(0, -1000)
var velocity_reduction_factor = 10.0
var jump_max_time = 0.25

var velocity = Vector2(0, 0)
var jump_cooldown = 0.0

var dash_curve_down: Curve
var dash_curve_up: Curve

var pushed: bool

func _ready() -> void:
	create_dash_curves()

func _physics_process(delta: float):
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
	dash_curve_up = Curve.new()
	dash_curve_up.add_point(Vector2(0, 0), 0, 0)
	dash_curve_up.add_point(Vector2(1, 100), 200, 200)
	
	dash_curve_down = Curve.new()
	dash_curve_down.add_point(Vector2(0, 0), 0, 0)
	dash_curve_down.add_point(Vector2(0.35, 20), 0, 0)
	dash_curve_down.add_point(Vector2(1, -100), -300, -300)
