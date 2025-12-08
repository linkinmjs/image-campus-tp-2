extends State
class_name ZombieHurted

@export var stun_time: float = 1.4  # tiempo “aturdido”

@onready var enemy: CharacterBody3D = get_parent().get_parent()
@onready var player: CharacterBody3D = enemy.player
@onready var animation_tree: AnimationTree = $"../../AnimationTree"

var animation_playback: AnimationNodeStateMachinePlayback
var timer: float = 0.0

func _ready() -> void:
	animation_playback = animation_tree.get("parameters/playback")
	
func enter() -> void:
	print("ZombieHurted state entered")
	timer = stun_time
	enemy.velocity = Vector3.ZERO
	animation_playback.travel("hurted")  # estado en AnimationTree

func exit() -> void:
	pass

func process(delta: float) -> void:
	timer -= delta
	if timer <= 0.0:
		# Cuando termina de estar herido, decide si perseguir o vagar
		if enemy.global_position.distance_to(player.global_position) < enemy.ChaseDistance:
			emit_signal("Transitioned", self, "ZombieChase")
		else:
			emit_signal("Transitioned", self, "ZombieWander")
