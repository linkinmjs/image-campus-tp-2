extends Node3D

const LEVEL_02_DIALOGUE = preload("uid://rumxgo15d0r2")

var dialogue_disabled: bool = false

func _ready() -> void:
	GameManager.ready_for_next_level.connect(_on_ready_for_next_level)

func _on_ready_for_next_level() -> void:
	if not dialogue_disabled:
		DialogueManager.show_dialogue_balloon(LEVEL_02_DIALOGUE, "end_level")
		dialogue_disabled = true
