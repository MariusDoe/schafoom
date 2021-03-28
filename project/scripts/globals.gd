extends Node

var level: int
var time: float
var potato_count: int
var in_game = false

func _physics_process(delta):
	if in_game:
		time += delta

func start_cutscene():
	get_tree().change_scene("res://scenes/Cutscene.tscn")

func start_game():
	level = 1
	time = 0.0
	potato_count = 0
	in_game = true
	get_tree().change_scene("res://scenes/game.tscn")

func dash(new_level: int):
	level = new_level
	get_tree().change_scene("res://scenes/game.tscn")

func die():
	in_game = false
	get_tree().change_scene("res://scenes/Game_Over.tscn")

func main_menu():
	get_tree().change_scene("res://scenes/Main_Menu.gd")

func quit():
	get_tree().quit()

func submit_score(name: String):
	# TODO
	print("Submit score ", time, " as ", name, "!")
