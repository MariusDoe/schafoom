extends Area2D

class_name Robot

var velocity = Vector2(0, 0)
export var jetpack = Vector2(0, -100)

var player: Player

var jetpack_enabled = false
var touching_wall = false

signal destroy(thing) 

func _ready() -> void:
	gravity = 800
	start_walking()

func start_jetpack() -> void:
	jetpack_enabled = true
	$Robot/AnimationPlayer.play("flying")
	$CollisionShape2D.rotation_degrees = 20
	$CollisionShape2D.position = Vector2(-45, -70)
	$"Robot/body/upper-body/jetpack/Particles2D".emitting = true
	
func start_falling() -> void:
	start_jetpack()
	$"Robot/body/upper-body/jetpack/Particles2D".emitting = false
	jetpack_enabled = false

func start_walking() -> void:
	jetpack_enabled = false
	$Robot/AnimationPlayer.play("walking")
	$CollisionShape2D.rotation_degrees = 0
	$CollisionShape2D.position = Vector2(0, 0)

func follow_player():
	if touching_wall:
		if position.y < 0:
			start_falling()
		else:
			start_jetpack()
		return
	if position.y > player.position.y:
		start_jetpack()
	else:
		start_falling()

func _physics_process(delta) -> void:
	follow_player()
	apply_gravity(delta)
	if jetpack_enabled:
		apply_jetpack(delta)
	
	move_robot(delta)

func move_robot(delta) -> void:
	position += velocity * delta

func apply_jetpack(delta) -> void:
	velocity = jetpack

func apply_gravity(delta) -> void:
	velocity += Vector2(0, gravity) * delta

func _on_RobotPhysics_body_entered(body):
	if body is Player:
		Globals.die()
		return
	if body is Wall:
		touching_wall = true
		return
	emit_signal("destroy", body)

func _on_RobotPhysics_body_exited(body):
	if body is Wall:
		touching_wall = false
		return

func get_size() -> Vector2:
	return $CollisionShape2D.shape.extents * 2
