extends PlayerState

func sm_enter(msg: Dictionary) -> void:
	player_owner.on_board = true
	player_owner.skate.visible = true

func sm_process(delta: float) -> void:
	#Si la velocidad baja demasiado tiene que transicionar a skateBoarding
	#if player_owner.input_direction.is_zero_approx():
		#state_machine.transition_to("Idle")
	if !player_owner.is_on_floor():
		state_machine.transition_to("InAir")
	elif !player_owner.is_running:
		state_machine.transition_to("SkateBoarding")

func sm_physics_process(delta: float) -> void:
	player_owner.velocity.x = lerp(player_owner.velocity.x, player_owner.SPRINT_SPEED_BOARDING * player_owner.input_direction.x, player_owner.FRICTION)
	player_owner.velocity.z = lerp(player_owner.velocity.z, player_owner.SPRINT_SPEED_BOARDING * player_owner.input_direction.z, player_owner.FRICTION)
	player_owner.move_and_slide()

func sm_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("x"):
		player_owner.on_board = !player_owner.on_board
		player_owner.skate.visible = !player_owner.skate.visible
		state_machine.transition_to("Sprint")
	
	#USADO POR AHORA PARA SIMULAR CAIDA
	elif Input.is_action_just_pressed("fall"):
		state_machine.transition_to("Fallen", {
			"knockback": -player_owner.transform.basis.z
		})

func sm_exit() -> void:
	pass

func sm_ready() -> void:
	pass
