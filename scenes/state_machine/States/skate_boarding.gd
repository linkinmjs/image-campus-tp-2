extends PlayerState

func sm_enter(msg: Dictionary) -> void:
	player_owner.on_board = true
	player_owner.skate.visible = true

func sm_process(delta: float) -> void:
	if player_owner.input_direction.is_zero_approx() and player_owner.velocity.length() < 0.2:
		player_owner.on_board = false
		player_owner.skate.visible = false
		state_machine.transition_to("Idle")
	elif !player_owner.is_on_floor():
		state_machine.transition_to("InAir")
	elif player_owner.is_running:
		state_machine.transition_to("SkateBoardingSprint")


func sm_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("x"):
		player_owner.on_board = !player_owner.on_board
		player_owner.skate.visible = !player_owner.skate.visible
		state_machine.transition_to("Walk")
	elif Input.is_action_just_released("jump"):
		state_machine.transition_to("InAir", {"doJump":true})
	#USADO POR AHORA PARA SIMULAR CAIDA
	elif Input.is_action_just_pressed("fall"):
		state_machine.transition_to("Fallen", {
			"knockback": -player_owner.transform.basis.z
		})


func sm_physics_process(delta: float) -> void:
	#player_owner.velocity.x = lerp(player_owner.velocity.x, player_owner.WALK_SPEED_BOARDING * player_owner.input_direction.x, player_owner.FRICTION)
	#player_owner.velocity.z = lerp(player_owner.velocity.z, player_owner.WALK_SPEED_BOARDING * player_owner.input_direction.z, player_owner.FRICTION)
	#player_owner.move_and_slide()
	var vel := player_owner.velocity
	# 1) Aceleración por rampa (si estás en piso)
	var slope := player_owner.get_slope_data()
	var tangent: Vector3 = slope["tangent"]
	if player_owner.is_on_floor() and !tangent.is_zero_approx():
		vel += tangent * player_owner.SKATE_SLOPE_ACCEL * delta
	# 2) Velocidad horizontal actual
	var horiz := Vector3(vel.x, 0.0, vel.z)
	var speed := horiz.length()
	# 3) Direcciones básicas
	var forward := -player_owner.transform.basis.z
	forward.y = 0.0
	if !forward.is_zero_approx():
		forward = forward.normalized()
	else:
		forward = Vector3.FORWARD
	# descomponer en componente hacia adelante y lateral
	var forward_speed := horiz.dot(forward)
	var lateral := horiz - forward * forward_speed
	# 4) Entrada de usuario
	var throttle := Input.get_axis("down", "up")   # W/S
	var steer := Input.get_axis("left", "right")   # A/D
	# 5) Girar con A/D (rotar el cuerpo, no moverse de costado)
	if abs(steer) > 0.01 and speed > 0.05:
		var turn_rate := 4.0  # probá entre 3 y 6 para afinar
		player_owner.rotate_y(-steer * turn_rate * delta)
		# actualizar forward después de girar
		forward = -player_owner.transform.basis.z
		forward.y = 0.0
		forward = forward.normalized()
	# 6) Acelerar / frenar tipo skate
	var max_speed := player_owner.SKATE_MAX_FLAT_SPEED
	var accel := player_owner.SKATE_PUSH_ACCEL * 0.5   # más suave que el sprint
	var brake_strength := player_owner.SKATE_PUSH_ACCEL   # freno fuerte con S
	var reverse_max_speed := 3.0   # qué tan rápido podés ir para atrás
	
	if throttle > 0.01:
		# W → acelerar hacia adelante
		forward_speed = min(forward_speed + accel * delta, max_speed)
	elif throttle < -0.01:
		# S → primero frena, luego empieza a ir despacio hacia atrás
		if forward_speed > 0.0:
			forward_speed = max(forward_speed - brake_strength * delta, 0.0)
		else:
			forward_speed = max(forward_speed - accel * delta, -reverse_max_speed)
	else:
		# sin W/S → fricción natural
		if forward_speed > 0.0:
			forward_speed = max(forward_speed - player_owner.SKATE_ROLL_FRICTION * delta, 0.0)
		elif forward_speed < 0.0:
			forward_speed = min(forward_speed + player_owner.SKATE_ROLL_FRICTION * delta, 0.0)
	# 7) Reducir el movimiento lateral (para que no se vaya de costado)
	lateral *= 0.2  # cuanto más bajo, menos derrape lateral
	# 8) Reconstruir la velocidad horizontal
	horiz = forward * forward_speed + lateral
	vel.x = horiz.x
	vel.z = horiz.z
	player_owner.velocity = vel
	player_owner.move_and_slide()

func sm_ready() -> void:
	pass

func sm_exit() -> void:
	pass
