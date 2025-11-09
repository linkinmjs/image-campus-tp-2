extends State
class_name EnemyAttack

@onready var enemy: CharacterBody3D = get_parent().get_parent()
@onready var player: CharacterBody3D = enemy.player



func process(delta: float):
	var enemy_attack = Attack.new(1.0, enemy)
	player.health_component.damage(enemy_attack)
	
	if enemy.global_position.distance_to(player.global_position) > enemy.AttackReach:
		emit_signal("Transitioned", self, "EnemyChase")
