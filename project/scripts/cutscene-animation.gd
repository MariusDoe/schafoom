extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var spawn_robot = false
export var walking = false
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
		
	if walking:
		robot_anim.play("walking")

func _input(event: InputEvent):
	if event.is_action_pressed("skip_cutscene"):
		end()

func end():
	Globals.start_game()
