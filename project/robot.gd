extends Area2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var velocity = Vector2(0, 0)
export var jetpack = Vector2(0, -100)

var player: Player

var jetpack_enabled = false

signal destroy(thing) 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gravity = 800
	start_walking()
	start_jetpack()
	start_falling()

func start_jetpack() -> void:
	jetpack_enabled = true
	$Robot/AnimationPlayer.play("flying")
	$CollisionShape2D.rotation_degrees = 20
	$CollisionShape2D.position = Vector2(-45, -70)
	$"Robot/body/upper-body/jetpack/Particles2D".emitting = true
	
func start_falling() -> void:
	$"Robot/body/upper-body/jetpack/Particles2D".emitting = false
	jetpack_enabled = false

func start_walking() -> void:
	jetpack_enabled = false
	$Robot/AnimationPlayer.play("walking")
	$CollisionShape2D.rotation_degrees = 0
	$CollisionShape2D.position = Vector2(0, 0)

func follow_player():
	if position.y > 300:
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
	
	print(position)

func apply_jetpack(delta) -> void:
	velocity = jetpack

func apply_gravity(delta) -> void:
	velocity += Vector2(0, gravity) * delta

func _on_RobotPhysics_body_entered(body):
	if body is Player:
		#Globals.die()
		return
	emit_signal("destroy", body)
