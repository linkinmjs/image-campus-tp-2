extends Area3D

@onready var scene_transition_helper: CanvasLayer = get_node("/root/Game/SceneTransitionHelper")
@onready var exit_area: Area3D = $"."
@export var next_level_scene: PackedScene

func _ready() -> void:
	exit_area.body_entered.connect(_on_area_body_entered)
	GameManager.screen_totally_black.connect(_on_screen_totally_black)

func _on_area_body_entered(body: Node3D) -> void:
	if body.name == "TestPlayer":
		print("player change level")
		scene_transition_helper.change_level()

func _on_screen_totally_black() -> void:
	var next_level_instance = next_level_scene.instantiate()
	get_parent().add_sibling(next_level_instance)
	get_parent().queue_free()
