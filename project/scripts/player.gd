extends KinematicBody2D

class_name Player

var gravity = Vector2(0, 600)
var jump_velocity = Vector2(0, -1000)
var velocity_reduction_factor = 10.0
var jump_max_time = 0.25

var velocity = Vector2(0, 0)
var jump_cooldown = 0.0

func _physics_process(delta: float):
	apply_jump_velocity(delta)
	add_gravity(delta)
	move_and_slide(velocity)

func jump_trigger() -> void:
	if not can_jump():
		return
	velocity = jump_velocity
	jump_cooldown = jump_max_time

func jump_release() -> void:
	jump_cooldown = 0.0

func can_jump() -> bool:
	return is_on_floor() or is_on_wall()

func add_gravity(delta: float) -> void:
	velocity += gravity * delta

func apply_jump_velocity(delta: float) -> void:
	jump_cooldown -= delta
	if jump_cooldown > 0.0:
		return
	if velocity.y < 0.0:
		velocity.y *= exp(-velocity_reduction_factor * delta)
