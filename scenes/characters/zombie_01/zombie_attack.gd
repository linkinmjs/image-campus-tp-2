extends State
class_name ZombieAttack

@onready var enemy: CharacterBody3D = get_parent().get_parent()
@onready var player: CharacterBody3D = enemy.player
@onready var animation_tree: AnimationTree = $"../../AnimationTree"

const DAMAGE: float = 25.0

var animation_playback: AnimationNodeStateMachinePlayback
var attacking: bool = false

func _ready() -> void:
	animation_playback = animation_tree.get("parameters/playback")

func enter():
	attacking = true
	animation_playback.travel("attacking")

func process(_delta: float):
	if enemy.global_position.distance_to(player.global_position) > enemy.AttackReach and not attacking: 
		emit_signal("Transitioned", self, "ZombieChase")

func _attack_player():
	var enemy_attack = AttackComponent.new(DAMAGE, enemy)
	if enemy.global_position.distance_to(player.global_position) <= enemy.AttackReach:
		player.health_component.damage(enemy_attack)
	attacking = false
