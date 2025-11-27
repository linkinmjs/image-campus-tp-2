extends PlayerState
#RUN
func sm_ready() -> void:
	pass

func sm_process(delta: float) -> void:
	if player_owner.input_direction.is_zero_approx():
		state_machine.transition_to("Idle")
	elif !player_owner.is_on_floor():
		state_machine.transition_to("InAir")
	elif !player_owner.is_running:
		state_machine.transition_to("Walk")

func sm_physics_process(delta: float) -> void:
	player_owner.velocity.x = lerp(player_owner.velocity.x, player_owner.SPRINT_SPEED * player_owner.input_direction.x, player_owner.FRICTION)
	player_owner.velocity.z = lerp(player_owner.velocity.z, player_owner.SPRINT_SPEED * player_owner.input_direction.z, player_owner.FRICTION)
	player_owner.move_and_slide()

func sm_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("InAir", {"doJump":true})

func sm_enter(msg: Dictionary) -> void:
	pass
