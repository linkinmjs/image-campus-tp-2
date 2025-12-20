extends Node

@onready var audio_rain_background: AudioStreamPlayer = $AudioManager/AudioRainBackground

var is_game_started: bool = false
var is_game_paused: bool = false

func _ready() -> void:
	audio_rain_background.play()
