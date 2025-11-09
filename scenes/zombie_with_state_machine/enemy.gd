extends CharacterBody3D

@export var WalkSpeed: float = 1.5
@export var RunSpeed: float = 4.0
@export var AttackReach: float = 1.5
@export var ChaseDistance: float = 10.0

@export var player: CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

# Enemigo creado a partir del siguiente tutorial:
# https://www.youtube.com/watch?v=NKYzlV9NWaw&list=PL0i6uRS5JlC73nROarUrJuzsJ_8v3Wbkw&index=3

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	move_and_slide()
	
func on_death() -> void:
	queue_free()
