extends Control


func _ready():
	pass


func _on_Start_pressed():
	get_tree().change_scene("res://scenes/Cutscene.tscn")


func _on_Exit_pressed():
	get_tree().quit()
