extends PlayerState
# Estado cuando el player se cayó del skate

func sm_ready() -> void:
	pass

func sm_enter(msg: Dictionary) -> void:
	# Soltar la tabla y crearla en el mundo
	player_owner.fall_from_board()
	# pequeño “knockback”
	if msg.has("knockback"):
		var dir: Vector3 = msg["knockback"]
		if not dir.is_zero_approx():
			player_owner.velocity = dir * 5.0

func sm_process(delta: float) -> void:
	# Estando caído, se “levanta”
	if player_owner.is_on_floor() and Input.is_action_just_pressed("jump"):
		player_owner.ignore_jump_once = true
		state_machine.transition_to("Idle")

func sm_physics_process(delta: float) -> void:
	# Se desliza un poco y frena
	player_owner.velocity.x = lerp(player_owner.velocity.x, 0.0, player_owner.FRICTION)
	player_owner.velocity.z = lerp(player_owner.velocity.z, 0.0, player_owner.FRICTION)
	player_owner.move_and_slide()

func sm_input(event: InputEvent) -> void:
	pass

func sm_exit() -> void:
	# Podés resetear flags si hace falta
	player_owner.player_fall_off = false
