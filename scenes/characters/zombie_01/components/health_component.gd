extends Node

@export var MaxHealth: float = 150.0 # default value recomended= 1000

var health: float = MaxHealth

func damage(attack: AttackComponent) -> void:
	print("damage func from health_component, damage =", attack.damage)
	print("health =", health)
	health -= attack.damage
	
	var parent: Node3D = get_parent()
	
	if health < 0:
		if parent.has_method("on_death"):
			parent.on_death()
	elif  health > 0 and parent.has_method("on_damage"):
		print("has_method on_damage")
		parent.on_damage(attack)
	
