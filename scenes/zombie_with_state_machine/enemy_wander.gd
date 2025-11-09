extends State
class_name EnemyWander

var wander_direction: Vector3
var wander_time: float = 0.0

@onready var enemy: CharacterBody3D = get_parent().get_parent()
@onready var player: CharacterBody3D = enemy.player

func randomize_variables():
	wander_time = randf_range(1.5, 4)
	if randi_range(0, 3) != 1:
		wander_direction = Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0))
	else:
		wander_direction = Vector3.ZERO
	
func enter():
	randomize_variables()

func process(delta: float):
	if wander_time < 0.0:
		randomize_variables()
		
	wander_time -= delta
	
	if enemy.global_position.distance_to(player.global_position) < enemy.ChaseDistance:
		emit_signal("Transitioned", self, "EnemyChase")
	
func physics_process(delta: float):
	enemy.velocity = wander_direction * enemy.WalkSpeed
	
	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity()
