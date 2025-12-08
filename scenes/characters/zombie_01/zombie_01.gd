extends CharacterBody3D

@export var WalkSpeed: float = 1.5
@export var RunSpeed: float = 4.0
@export var AttackReach: float = 1.5
@export var ChaseDistance: float = 10.0

@export var player: CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: ZombieStateMachine = $ZombieStateMachine
@onready var health_component: Node = $HealthComponent
@onready var head_area: Area3D = $body/Armature/Skeleton3D/Head/Area3D

var animation_playback: AnimationNodeStateMachinePlayback

# Enemigo creado a partir del siguiente tutorial:
# https://www.youtube.com/watch?v=NKYzlV9NWaw&list=PL0i6uRS5JlC73nROarUrJuzsJ_8v3Wbkw&index=3

func _ready() -> void:
	animation_playback = animation_tree.get("parameters/playback")
	head_area.body_entered.connect(_on_head_area_body_entered)

func _physics_process(delta: float) -> void:
	var state = animation_playback.get_current_node()
	
	if state == "attacking":
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z))
		return
	else:
		var new_velocity = velocity
		new_velocity.y = 0
		
		if new_velocity != Vector3.ZERO:
			rotation.y = lerp(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
		
	move_and_slide()

# Llamado por HealthComponent cuando sufre daño
func on_damage(attack: AttackComponent):
	state_machine.change_state("ZombieHurted")

# Llamado por HealthComponent cuando muere
func on_death() -> void:
	print("on_death llamado")
	state_machine.change_state("ZombieKilled")

# Golpe estilo “Mario” al saltar sobre la cabeza
func _on_head_area_body_entered(body: Node3D) -> void:
	if body != player:
		return
	
	# Asegurarse de que el player viene cayendo
	if not (body is CharacterBody3D):
		return
		
	var player_body := body as CharacterBody3D
	if player_body.velocity.y >= 0.0:
		return  # no viene desde arriba, ignorar
	
	# Rebote del jugador hacia arriba
	player_body.velocity.y = 10.0
	
	# Daño al zombie
	var head_stomp_damage: float = 200.0  # o expórtalo como @export var
	var attack := AttackComponent.new(head_stomp_damage, player_body)
	print("Head stomp: applying damage =", attack.damage)
	health_component.damage(attack)
