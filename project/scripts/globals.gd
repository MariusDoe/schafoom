extends Node

var level: int
var time: float
var potato_count: int
var in_game = false

const GAME_NAME = "schafoom"

var uploading = UPLOADING.NOT_YET

enum Uploading {
	NOT_YET,
	IN_PROGRESS,
	SUCCESS,
}

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
	if uploading != Uploading.NOT_YET:
		return
	uploading = Uploading.IN_PROGRESS
	var success = upload_time(name, time)
	if success:
		uploading = Uploading.SUCCESS
	else:
		uploading = Uploading.NOT_YET

var upload_status: String

func get_response(http_request: HTTPRequest, url: String) -> String:
	if http_request.request(url, [], true, HTTPClient.METHOD_POST) != OK:
		upload_status = "Sending score failed"
		return null
	var response = yield(http_request, "request_completed")
	if response[1] != 200:
		upload_status = "Sending score returned " + str(response[1])
		return null
	return response

func upload_time(name: String, score: float):
	upload_status = "Uploading the score " + str(score) + " as " + name + "..."
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var url = ("https://scores.tmbe.me/score?game=" + GAME_NAME.percent_encode() +
		"&player=" + name.percent_encode() +
		"&score=" + str(score).percent_encode())
	
	var response = get_response(http_request, url)
	remove_child(http_request)
	
	if response == null:
		return false
	
	var res = JSON.parse(response[3].get_string_from_utf8()).result
	if res.has("position"):
		var position = res["position"]
		upload_status = "Highscore submitted! - You scored position " \
				+ str(position)
		return false
	upload_status = "Something went wrong..."
	return true

func is_level_ok(level: int) -> bool:
	return level >= 0 and level <= 2
