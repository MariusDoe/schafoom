extends Node

var level: int
var time: float
var potato_count: int
var in_game = false

const GAME_NAME = "schafoom"

var uploading = Uploading.NOT_YET

enum Uploading {
	NOT_YET,
	IN_PROGRESS,
	SUCCESS,
}

var music_player: AudioStreamPlayer

func _ready():
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	main_menu()

func _physics_process(delta):
	if in_game:
		time += delta

func start_cutscene():
	get_tree().change_scene("res://scenes/Cutscene.tscn")
	music_player.stop()

func start_game():
	level = 1
	time = 0.0
	potato_count = 0
	get_tree().change_scene("res://scenes/game.tscn")
	in_game = true
	var stream = preload("res://sfx/Music/Juhani Junkala [Chiptune Adventures] 1. Stage 1.wav")
	stream.loop_mode = AudioStreamSample.LOOP_FORWARD
	stream.loop_end = stream.get_length() * stream.mix_rate
	var volume = -15
	set_music(stream, volume)

func dash(new_level: int):
	level = new_level
	get_tree().change_scene("res://scenes/game.tscn")

func die():
	in_game = false
	get_tree().change_scene("res://scenes/Game_Over.tscn")
	var stream = preload("res://sfx/Wilhelm_Scream.ogg")
	stream.loop = false
	var volume = -5
	set_music(stream, volume)

func main_menu():
	get_tree().change_scene("res://scenes/Main_Menu.gd")
	var stream = preload("res://sfx/Music/Juhani Junkala [Chiptune Adventures] 2. Stage2.wav")
	stream.loop_mode = AudioStreamSample.LOOP_FORWARD
	stream.loop_end = stream.get_length() * stream.mix_rate
	var volume = -15
	set_music(stream, volume)

func quit():
	get_tree().quit()

func submit_score(name: String):
	if uploading != Uploading.NOT_YET:
		return
	uploading = Uploading.IN_PROGRESS
	var success = upload_time(name, time)
	if success is GDScriptFunctionState:
		success = yield(success, "completed")
	if success:
		uploading = Uploading.SUCCESS
	else:
		uploading = Uploading.NOT_YET

func get_response(http_request: HTTPRequest, url: String) -> Array:
	if http_request.request(url, [], true, HTTPClient.METHOD_POST) != OK:
		show_upload_status("Sending score failed")
		return null
	var response = yield(http_request, "request_completed")
	if response[1] != 200:
		show_upload_status("Sending score returned " + str(response[1]))
		return null
	return response

func upload_time(name: String, score: float):
	show_upload_status("Uploading the score " + str(score) + " as " + name + "...")
	var http_request = HTTPRequest.new()
	add_child(http_request)

	var url = ("https://scores.tmbe.me/score?game=" + GAME_NAME.percent_encode() +
		"&player=" + name.percent_encode() +
		"&score=" + get_formatted_score().percent_encode())

	var response = get_response(http_request, url)
	
	if response is GDScriptFunctionState:
		response = yield(response, "completed")
	
	remove_child(http_request)
	
	if response == null:
		return false
	
	var res = JSON.parse(response[3].get_string_from_utf8()).result
	if res.has("position"):
		var position = res["position"]
		show_upload_status("Score submitted! - You scored position " \
				+ str(position))
		return true
	show_upload_status("Something went wrong...")
	return false

func is_level_ok(level: int) -> bool:
	return level >= 0 and level <= 2

func set_music(stream: AudioStream, volume: float) -> void:
	music_player.stop()
	music_player.stream = stream
	music_player.volume_db = volume
	music_player.play()

func get_formatted_score() -> String:
	return "%.1f" % time

func show_upload_status(text: String) -> void:
	var status = get_node("/root/Game_Over/Background/Upload_Status")
	status.text = text
