extends Node

@export var MaxHealth: float = 1000.0

var health: float = MaxHealth

func damage(attack: Attack) -> void:
	health -= attack.damage
	
	var parent: Node3D = get_parent()
	
	if health <= 0:
		if parent.has_method("on_death"):
			parent.on_death()
	
	if parent.has_method("on_damage"):
		parent.on_damage(attack)
	
