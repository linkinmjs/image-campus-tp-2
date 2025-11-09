extends State
class_name EnemyChase

@onready var enemy: CharacterBody3D = get_parent().get_parent()
@onready var player: CharacterBody3D = enemy.player


func _ready() -> void:
	pass

func process(delta: float):
	enemy.navigation_agent.set_target_position(player.global_position)
	
	if enemy.global_position.distance_to(player.global_position) > enemy.ChaseDistance:
		emit_signal("Transitioned", self, "EnemyWander")
	
	if enemy.global_position.distance_to(player.global_position) < enemy.AttackReach:
		emit_signal("Transitioned", self, "EnemyAttack")
		
func physics_process(delta: float):
	if enemy.navigation_agent.is_navigation_finished():
		return
		
	var next_position: Vector3 = enemy.navigation_agent.get_next_path_position()
	enemy.velocity = enemy.global_position.direction_to(next_position) * enemy.RunSpeed
	
