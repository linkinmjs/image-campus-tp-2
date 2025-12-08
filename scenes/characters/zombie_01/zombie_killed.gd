extends State
class_name ZombieKilled

@export var death_duration: float = 1.0  # duración de la animación de muerte

@onready var enemy: CharacterBody3D = get_parent().get_parent()
@onready var animation_tree: AnimationTree = $"../../AnimationTree"

var animation_playback: AnimationNodeStateMachinePlayback
var timer: float = 0.0

func _ready() -> void:
	animation_playback = animation_tree.get("parameters/playback")
	
func enter() -> void:
	timer = death_duration
	enemy.velocity = Vector3.ZERO
	
	if enemy.has_node("NavigationAgent3D"):
		enemy.navigation_agent.set_enabled(false)

	animation_playback.travel("dead")
	
func process(delta: float) -> void:
	timer -= delta
	if timer <= 0.0:
		enemy.queue_free()
