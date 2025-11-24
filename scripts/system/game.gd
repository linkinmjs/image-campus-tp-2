extends Node

@onready var audio_rain_background: AudioStreamPlayer = $Audios/AudioRainBackground

var is_game_started: bool = false
var is_game_paused: bool = false

#Songs
@onready var song_01: AudioStreamPlayer = $Audios/Song01
@onready var song_02: AudioStreamPlayer = $Audios/Song02
@onready var song_03: AudioStreamPlayer = $Audios/Song03
@onready var song_04: AudioStreamPlayer = $Audios/Song04
@onready var song_05: AudioStreamPlayer = $Audios/Song05
@onready var song_06: AudioStreamPlayer = $Audios/Song06
@onready var song_07: AudioStreamPlayer = $Audios/Song07

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_rain_background.play()

func start_game() -> void:
	# go to intro/tutorial
	pass
