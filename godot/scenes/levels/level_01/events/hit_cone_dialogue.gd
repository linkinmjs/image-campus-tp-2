extends Node3D

@onready var area_3d: Area3D = $Area3D

const WAIT_FOR_RAIN_STOP = preload("uid://c3she45csmg7a")

var is_dialogue_active: bool = false
var dialogue_disabled: bool = false

func _ready() -> void:
	area_3d.body_entered.connect(_on_area_body_entered)
	
func _on_area_body_entered(_body: Node3D):
	if not dialogue_disabled:
		DialogueManager.show_dialogue_balloon(WAIT_FOR_RAIN_STOP, "tutorial")
		dialogue_disabled = true
