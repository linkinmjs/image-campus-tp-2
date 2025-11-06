extends CharacterBody3D

var player = null
var hp: float = 15.0
var state_machine

const SPEED = 5.0
const ATTACK_RANGE = 2.0
const DAMAGE = 2.0

@export var player_path: NodePath
@onready var nav_agent = $NavigationAgent3D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var hit_area: Area3D = $HitArea

func _ready() -> void:
	player = get_node(player_path)
	state_machine = animation_tree.get('parameters/playback')
	hit_area.body_entered.connect(zombie_hitted)


func _physics_process(_delta: float) -> void:
	match state_machine.get_current_node():
		"idle":
			animation_tree.set('parameters/conditions/running', true)
		"running":
			velocity = Vector3.ZERO
			
			nav_agent.set_target_position(player.global_position)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_position).normalized() * SPEED
			look_at(Vector3(next_nav_point.x, global_position.y, next_nav_point.z), Vector3.UP)
			animation_tree.set('parameters/conditions/attack', target_on_range())
			move_and_slide()
		"attack":
			animation_tree.set('parameters/conditions/running', !target_on_range())
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		"hitted":
			animation_tree.set('parameters/conditions/hitted', false)
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		"dying":
			collision_shape_3d.disabled = true
		
		

func hit_player():
	if target_on_range():
		print("Player Golpeado!")

func zombie_hitted(_body) -> void:
	print("Zombie Golpeado!")
	hp -= 1
	if hp <= 0:
		animation_tree.set('parameters/conditions/dying', true)
	else:
		animation_tree.set('parameters/conditions/hitted', true)

func target_on_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE
