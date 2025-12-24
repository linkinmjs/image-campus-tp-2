extends PlayerState

func sm_enter(msg: Dictionary) -> void:
	player_owner.on_board = true
	player_owner.skate.visible = true

func sm_process(delta: float) -> void:
	#Si la velocidad baja demasiado tiene que transicionar a skateBoarding
	#if player_owner.input_direction.is_zero_approx():
		#state_machine.transition_to("Idle")
	if !player_owner.is_running:
		state_machine.transition_to("SkateBoarding")
	elif not player_owner.is_on_floor():
		# vamos a InAir aunque no haya doJump
		var slope := player_owner.get_slope_data()
		var angle_deg: float = slope["angle_deg"]
		var allow_air_rotation := angle_deg >= player_owner.TRICK_MIN_SLOPE_DEG
		
		state_machine.transition_to("InAir", {
			"allow_air_rotation": allow_air_rotation
		})


func sm_input(event: InputEvent) -> void:
	var slope := player_owner.get_slope_data()
	var angle_deg: float = slope["angle_deg"]
	var allow_air_rotation := angle_deg >= player_owner.TRICK_MIN_SLOPE_DEG
	print(allow_air_rotation)
	if Input.is_action_just_pressed("x"):
		player_owner.on_board = !player_owner.on_board
		player_owner.skate.visible = !player_owner.skate.visible
		state_machine.transition_to("Sprint")
	#USADO POR AHORA PARA SIMULAR CAIDA
	elif Input.is_action_just_pressed("fall"):
		state_machine.transition_to("Fallen", {
			"knockback": -player_owner.transform.basis.z
		})
	elif Input.is_action_just_released("jump") and allow_air_rotation and player_owner.is_on_floor() and player_owner.on_board:
		state_machine.transition_to("InAir", {
			"doJump": true,
			"allow_air_rotation": allow_air_rotation
		})
	elif Input.is_action_just_released("jump"):
		state_machine.transition_to("InAir", {"doJump":true})


func sm_physics_process(delta: float) -> void:
	#player_owner.velocity.x = lerp(player_owner.velocity.x, player_owner.SPRINT_SPEED_BOARDING * player_owner.input_direction.x, player_owner.FRICTION)
	#player_owner.velocity.z = lerp(player_owner.velocity.z, player_owner.SPRINT_SPEED_BOARDING * player_owner.input_direction.z, player_owner.FRICTION)
	#player_owner.move_and_slide()
	
	var vel := player_owner.velocity
	# 1) Aceleración por rampa
	var slope := player_owner.get_slope_data()
	var angle_deg: float = slope["angle_deg"]
	var tangent: Vector3 = slope["tangent"]
	if player_owner.is_on_floor() and !tangent.is_zero_approx():
		vel += tangent * player_owner.SKATE_SLOPE_ACCEL * delta
	# 2) Velocidad horizontal actual
	var horiz := Vector3(vel.x, 0.0, vel.z)
	var speed := horiz.length()
	# 3) Forward y componentes
	var forward := -player_owner.transform.basis.z
	forward.y = 0.0
	if !forward.is_zero_approx():
		forward = forward.normalized()
	else:
		forward = Vector3.FORWARD
	var forward_speed := horiz.dot(forward)
	var lateral := horiz - forward * forward_speed
	# 4) Input de usuario
	var throttle := Input.get_axis("down", "up")   # W/S
	var steer := Input.get_axis("left", "right")   # A/D
	# 5) Girar en sprint (curva un poco más abierta que en SkateBoarding)
	if abs(steer) > 0.01 and speed > 0.05:
		var turn_rate := 2.5  # más bajo → curva más abierta (probá 2–4)
		player_owner.rotate_y(-steer * turn_rate * delta)
		forward = -player_owner.transform.basis.z
		forward.y = 0.0
		forward = forward.normalized()
	# 6) Aceleración fuerte tipo “push”
	var max_speed := player_owner.SKATE_MAX_SPRINT_SPEED
	var accel := player_owner.SKATE_PUSH_ACCEL
	var brake_strength := player_owner.SKATE_PUSH_ACCEL * 1.2
	var reverse_max_speed := 3.0
	if throttle > 0.01:
		# W + sprint → push fuerte
		if angle_deg <= player_owner.SKATE_MAX_PUSH_SLOPE_DEG:
			forward_speed = min(forward_speed + accel * delta, max_speed)
	elif throttle < -0.01:
		# S en sprint → frena muy fuerte
		if forward_speed > 0.0:
			forward_speed = max(forward_speed - brake_strength * delta, 0.0)
		else:
			forward_speed = max(forward_speed - accel * delta, -reverse_max_speed)
	else:
		# sin W/S pero todavía en sprint → un poco de fricción
		if forward_speed > 0.0:
			forward_speed = max(forward_speed - player_owner.SKATE_ROLL_FRICTION * 0.7 * delta, 0.0)
		elif forward_speed < 0.0:
			forward_speed = min(forward_speed + player_owner.SKATE_ROLL_FRICTION * 0.7 * delta, 0.0)
	# 7) Reducir derrape lateral
	lateral *= 0.2
	# 8) Reconstruir velocidad horizontal
	horiz = forward * forward_speed + lateral
	vel.x = horiz.x
	vel.z = horiz.z
	player_owner.velocity = vel
	player_owner.move_and_slide()


func sm_exit() -> void:
	pass

func sm_ready() -> void:
	pass
