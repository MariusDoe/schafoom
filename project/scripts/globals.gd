extends Node

var level: int
var time: float
var potato_count: int
var in_game = false

var music_player: AudioStreamPlayer

func _ready():
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	main_menu()

func _physics_process(delta):
	if in_game:
		time += delta

func start_cutscene():
	#var stream = preload("res://sfx/Music/Juhani Junkala [Chiptune Adventures] 1. Stage 1.wav")
	#stream.loop_mode = AudioStreamSample.LOOP_FORWARD
	#stream.loop_end = stream.get_length() * stream.mix_rate
	#var volume = -15
	#set_music(stream, volume)
	music_player.stop()
	get_tree().change_scene("res://scenes/Cutscene.tscn")

func start_game():
	level = 1
	time = 0.0
	potato_count = 0
	in_game = true
	var stream = preload("res://sfx/Music/Juhani Junkala [Chiptune Adventures] 1. Stage 1.wav")
	stream.loop_mode = AudioStreamSample.LOOP_FORWARD
	stream.loop_end = stream.get_length() * stream.mix_rate
	var volume = -15
	set_music(stream, volume)
	get_tree().change_scene("res://scenes/game.tscn")

func dash(new_level: int):
	level = new_level
	get_tree().change_scene("res://scenes/game.tscn")

func die():
	in_game = false
	var stream = preload("res://sfx/Player/death_jack_01.wav")
	var volume = -5
	set_music(stream, volume)
	get_tree().change_scene("res://scenes/Game_Over.tscn")

func main_menu():
	var stream = preload("res://sfx/Music/Juhani Junkala [Chiptune Adventures] 2. Stage2.wav")
	stream.loop_mode = AudioStreamSample.LOOP_FORWARD
	stream.loop_end = stream.get_length() * stream.mix_rate
	var volume = -15
	set_music(stream, volume)
	get_tree().change_scene("res://scenes/Main_Menu.gd")

func quit():
	get_tree().quit()

func submit_score(name: String):
	# TODO
	print("Submit score ", time, " as ", name, "!")

func is_level_ok(level: int) -> bool:
	return level >= 0 and level <= 2

func set_music(stream: AudioStream, volume: float) -> void:
	music_player.stop()
	music_player.stream = stream
	music_player.volume_db = volume
	music_player.play()
