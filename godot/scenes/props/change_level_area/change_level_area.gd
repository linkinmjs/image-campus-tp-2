extends Area3D

@onready var exit_area: Area3D = $"."
@onready var scene_transition_helper: CanvasLayer = get_node("/root/Game/SceneTransitionHelper")
@export var next_level_scene: PackedScene

@onready var effects: Node3D = $Effects
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var ready_for_next_level: bool = false

func _ready() -> void:
	exit_area.body_entered.connect(_on_area_body_entered)
	GameManager.screen_totally_black.connect(_on_screen_totally_black)
	GameManager.ready_for_next_level.connect(_on_ready_for_next_level)

func _on_ready_for_next_level():
	ready_for_next_level = true
	collision_shape.show()
	effects.show()

func _on_area_body_entered(body: Node3D) -> void:
	if body.name == "TestPlayer" or body.name == "Player" and ready_for_next_level:
		print("player change level")
		scene_transition_helper.change_level()

func _on_screen_totally_black() -> void:
	var next_level_instance = next_level_scene.instantiate()
	get_parent().add_sibling(next_level_instance)
	get_parent().queue_free()
