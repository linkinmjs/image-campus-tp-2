extends CharacterBody3D

@export var WalkSpeed: float = 1.5
@export var RunSpeed: float = 4.0
@export var AttackReach: float = 1.5

@export var player: CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

# Enemigo creado a partir del siguiente tutorial:
# https://www.youtube.com/watch?v=NKYzlV9NWaw&list=PL0i6uRS5JlC73nROarUrJuzsJ_8v3Wbkw&index=3

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	navigation_agent.set_target_position(player.global_position)
	
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z))
	
	if player.global_position.distance_to(global_position) < AttackReach:
		var attack: Attack = Attack.new(1.0, self)
		player.health_component.damage(attack)
		
	
func _physics_process(delta: float) -> void:
	process_move()

func process_move() -> void:
	if navigation_agent.is_navigation_finished():
		return
		
	var next_position: Vector3 = navigation_agent.get_next_path_position()
	velocity = global_position.direction_to(next_position) * WalkSpeed
	
	move_and_slide()
	
	
func on_death() -> void:
	queue_free()
	
	
	
	
	
	
	
	
