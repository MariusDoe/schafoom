extends CanvasLayer


func _process(delta):
	$Potato_Count/Banner/Potato_Count.text = str(Globals.potato_count)
	$Score/Banner/Score.text = Globals.get_formatted_score()

