extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var spawn_robot = false
onready var robot_anim = $Monitor1/MonitorContent/Zoom/Robot/AnimationPlayer
var already_played = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if spawn_robot and not already_played:
		robot_anim.play("creation")
		already_played = true
