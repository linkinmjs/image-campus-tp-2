extends State
class_name EnemyAttack

@onready var enemy: CharacterBody3D = get_parent().get_parent()
@onready var player: CharacterBody3D = enemy.player
@onready var animation_tree: AnimationTree = $"../../AnimationTree"

var animation_playback: AnimationNodeStateMachinePlayback

func _ready() -> void:
	animation_playback = animation_tree.get("parameters/playback")

func enter():
	animation_playback.travel("attacking")

func process(delta: float):
	if enemy.global_position.distance_to(player.global_position) > enemy.AttackReach:
		emit_signal("Transitioned", self, "EnemyChase")

func _attack_player():
	var enemy_attack = Attack.new(15.0, enemy)
	player.health_component.damage(enemy_attack)
