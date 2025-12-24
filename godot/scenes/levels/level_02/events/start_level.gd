extends Node3D

@onready var area_3d: Area3D = $Area3D

const LEVEL_02_DIALOGUE = preload("uid://rumxgo15d0r2")

var dialogue_disabled: bool = false

func _ready() -> void:
	area_3d.body_exited.connect(_on_body_exited)

func _on_body_exited(body: Node3D) -> void:
	if not dialogue_disabled:
		DialogueManager.show_dialogue_balloon(LEVEL_02_DIALOGUE)
		dialogue_disabled = true
