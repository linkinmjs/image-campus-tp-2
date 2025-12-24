extends PlayerState
#IDLE

func sm_ready() -> void:
	pass

func sm_process(delta: float) -> void:
	if !player_owner.input_direction.is_zero_approx():
		if player_owner.on_board:
			if !player_owner.has_board_equipped:
				return
			state_machine.transition_to("SkateBoarding")
		else:
			state_machine.transition_to("Walk")
	elif !player_owner.is_on_floor():
		state_machine.transition_to("InAir")


func sm_physics_process(delta: float) -> void:
	player_owner.velocity = lerp(player_owner.velocity, Vector3.ZERO, player_owner.FRICTION)
	player_owner.move_and_slide()

func sm_input(event: InputEvent) -> void:
	if player_owner.ignore_jump_once:
		if Input.is_action_just_released("jump"):
			player_owner.ignore_jump_once = false
		return
	if Input.is_action_just_released("jump"):
		state_machine.transition_to("InAir", {"doJump":true})
	elif Input.is_action_just_pressed("crouch"):
		state_machine.transition_to("Crouch")
	elif Input.is_action_just_pressed("x"):
		if !player_owner.has_board_equipped:
			return
		player_owner.on_board = !player_owner.on_board
		player_owner.skate.visible = !player_owner.skate.visible



func sm_enter(msg: Dictionary) -> void:
	pass
