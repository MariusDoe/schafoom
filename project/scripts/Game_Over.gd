extends Control

func _ready():
	$Background/Score.text = Globals.get_formatted_score()

func _on_Try_Again_pressed():
	Globals.start_game() 


func _on_Send_Button_pressed():
	var name = $Background/Name.text
	Globals.submit_score(name)
