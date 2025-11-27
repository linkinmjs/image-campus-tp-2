extends PlayerState
#IDLE

func sm_ready() -> void:
	pass

func sm_process(delta: float) -> void:
	if !player_owner.input_direction.is_zero_approx():
		state_machine.transition_to("Walk")
	elif !player_owner.is_on_floor():
		state_machine.transition_to("InAir")


func sm_physics_process(delta: float) -> void:
	player_owner.velocity = lerp(player_owner.velocity, Vector3.ZERO, player_owner.FRICTION)
	player_owner.move_and_slide()

func sm_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("InAir", {"doJump":true})
	elif Input.is_action_just_pressed("crouch"):
		state_machine.transition_to("Crouch")

func sm_enter(msg: Dictionary) -> void:
	pass
