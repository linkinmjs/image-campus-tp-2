class_name StateMachinePlayer
extends Node

signal transitioned(state_name)

@export var initial_state := NodePath()
@onready var state = get_node(initial_state)
@export var player: PlayerTest
@export var camera_3d: Camera3D
@export var collision_shape_player: CollisionShape3D
@export var label_state: Label
func _ready() -> void:
	#Espera al que se inicie el padre
	await owner.ready
	for child in get_children():
		child.state_machine = self
		child.sm_ready()
	state.sm_enter({})


func _unhandled_input(event: InputEvent) -> void:
	state.sm_input(event)

func _process(delta: float) -> void:
	label_state.text = state.name
	state.sm_process(delta)

func _physics_process(delta: float) -> void:
	state.sm_physics_process(delta)

func transition_to(new_state : String, msg: Dictionary = {}):
	assert(has_node(new_state), "El estado no funciona, [func transition_to]")
	state.sm_exit()
	state = get_node(new_state)
	state.sm_enter(msg)
	transitioned.emit(new_state)
