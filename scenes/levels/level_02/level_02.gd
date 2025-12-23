extends Node3D

@onready var scene_transition_helper: CanvasLayer = get_node("/root/Game/SceneTransitionHelper")
@export var next_level: PackedScene

var zombies_killed_count = 0

func _ready() -> void:
	GameManager.zombie_has_been_killed.connect(_on_zombie_killed)
	GameManager.screen_totally_black.connect(_on_screen_totally_black)

func _process(delta: float) -> void:
	if zombies_killed_count < 4:
		return
	scene_transition_helper.change_level()

func _on_zombie_killed() -> void:
	zombies_killed_count += 1
	
func _on_screen_totally_black() -> void:
	var next_level_instance = next_level.instantiate()
	get_parent().add_sibling(next_level_instance)
	get_parent().queue_free()


	
