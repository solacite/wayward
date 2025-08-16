extends Node

var waves: AudioStreamPlayer
var music: AudioStreamPlayer
var button: AudioStreamPlayer
var coin: AudioStreamPlayer
var pressure: AudioStreamPlayer

func _ready():
	waves = AudioStreamPlayer.new()
	music = AudioStreamPlayer.new()
	button = AudioStreamPlayer.new()
	coin = AudioStreamPlayer.new()
	pressure = AudioStreamPlayer.new()
	
	add_child(waves)
	add_child(music)
	add_child(button)
	add_child(coin)
	add_child(pressure)
	
	waves.stream = preload("res://audio/sea-waves.mp3")
	music.stream = preload("res://audio/wayward.mp3")
	button.stream = preload("res://audio/tap.mp3")
	coin.stream = preload("res://audio/coin.mp3")
	pressure.stream = preload("res://audio/pop.mp3")
	
	waves.stream.loop = true
	music.stream.loop = true
	
	waves.volume_db = -15
	music.volume_db = -10
	button.volume_db = -10
	pressure.volume_db = -15
	
	waves.play()
	music.play()

func play_button_sound():
	button.play()
	
func play_coin_sound():
	coin.play()
	
func play_pop_sound():
	pressure.play()
