extends CharacterBody3D

@export var WalkSpeed: float = 1.5
@export var RunSpeed: float = 4.0
@export var AttackReach: float = 1.5
@export var ChaseDistance: float = 10.0

@export var player: CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_tree: AnimationTree = $AnimationTree

var animation_playback: AnimationNodeStateMachinePlayback

# Enemigo creado a partir del siguiente tutorial:
# https://www.youtube.com/watch?v=NKYzlV9NWaw&list=PL0i6uRS5JlC73nROarUrJuzsJ_8v3Wbkw&index=3

func _ready() -> void:
	animation_playback = animation_tree.get("parameters/playback")

func _physics_process(delta: float) -> void:
	var state = animation_playback.get_current_node()
	
	if state == "attacking":
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z))
		return
	else:
		var new_velocity = velocity
		new_velocity.y = 0
		
		if new_velocity != Vector3.ZERO:
			rotation.y = lerp(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
		
	move_and_slide()
	
func on_death() -> void:
	queue_free()
