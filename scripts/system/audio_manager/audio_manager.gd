extends Node

# Menú
@onready var audio_button_move: AudioStreamPlayer = %AudioButtonMove
@onready var audio_button_select: AudioStreamPlayer = %AudioButtonSelect
@onready var audio_button_select_with_zombie: AudioStreamPlayer = %AudioButtonSelectWithZombie

# Rain effect
@onready var audio_rain_background: AudioStreamPlayer = $AudioRainBackground

# Songs
@onready var song_01: AudioStreamPlayer = $Song01
@onready var song_02: AudioStreamPlayer = $Song02
@onready var song_03: AudioStreamPlayer = $Song03
@onready var song_04: AudioStreamPlayer = $Song04
@onready var song_05: AudioStreamPlayer = $Song05
@onready var song_06: AudioStreamPlayer = $Song06
@onready var song_07: AudioStreamPlayer = $Song07

var _rain_fade_tween: Tween
var _playlist_running := false

func _ready() -> void:
	GameManager.tutorial_finished.connect(_on_tutorial_finished)
	GameManager.rain_stopped.connect(_on_rain_stopped)
	
func _on_tutorial_finished() -> void:
	if _rain_fade_tween and _rain_fade_tween.is_valid():
		_rain_fade_tween.kill()
	
	_rain_fade_tween = get_tree().create_tween()
	
	_rain_fade_tween = get_tree().create_tween()
	_rain_fade_tween.set_trans(Tween.TRANS_SINE)
	_rain_fade_tween.set_ease(Tween.EASE_IN_OUT)
	_rain_fade_tween.tween_property(audio_rain_background, "volume_db", -45.0, 4.0)
	_rain_fade_tween.tween_callback(audio_rain_background.stop)
	
	_rain_fade_tween.tween_callback(func():
		audio_rain_background.stop()
		audio_rain_background.volume_db = 0.0
		GameManager.emit_rain_stopped()
	)

func _on_rain_stopped() -> void:
	if _playlist_running:
		return
	_playlist_running = true

	var songs: Array[AudioStreamPlayer] = [
		song_01, song_02, song_03, song_04, song_05, song_06, song_07
	]

	for s in songs:
		if not is_instance_valid(s) or s.stream == null:
			continue
		s.play()
		await s.finished

	_playlist_running = false
