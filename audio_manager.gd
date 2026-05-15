extends Node

@onready var bgm_player = AudioStreamPlayer.new()

func _ready():
	add_child(bgm_player)
	bgm_player.stream = load("res://assets/sound/Game music.mp3")
	bgm_player.bus = "Music"
	bgm_player.play()
