extends PlayerState
#INAIR



var allow_trajectory_steer: bool = false
var locked_horizontal_velocity: Vector3 = Vector3.ZERO

# Para control de trucos (si ya lo usás)
var allow_air_rotation: bool = false
# Para control de trayectoria con la cámara
var air_base_dir: Vector3 = Vector3.ZERO
var air_head_yaw_start: float = 0.0
  
func sm_ready() -> void:
	pass


func sm_process(delta: float) -> void:
	# Cuando toca el piso, decidir si es una caída o un aterrizaje limpio
	if player_owner.is_on_floor():
		var floor_normal: Vector3 = player_owner.get_floor_normal()
		var vel: Vector3 = player_owner.velocity
		var horiz_vel := Vector3(vel.x, 0.0, vel.z)
		var horiz_speed := horiz_vel.length()
		# ¿Está "boca abajo" al tocar el suelo?
		var visual_up: Vector3
		if player_owner.skate:
			visual_up = player_owner.skate.global_transform.basis.y
		else:
			visual_up = player_owner.transform.basis.y
		
		var upside_dot := visual_up.dot(floor_normal)
		# 1 = totalmente de pie, 0 = a 90°, <0 = boca abajo.
		# Si está muy inclinado (más de ~70°) lo consideramos caída.
		var UPSIDE_FALL_THRESHOLD := 0.3   # podés probar 0.4 / 0.2 según feeling
		if upside_dot < UPSIDE_FALL_THRESHOLD:
			var knock_dir := horiz_vel.normalized() if horiz_speed > 0.1 else -floor_normal
			state_machine.transition_to("Fallen", {"knockback": knock_dir})
			return
		# Cálculo de impacto "normal"
		# Componente de la velocidad en la dirección de la normal (impacto "vertical")
		var impact_speed := -vel.dot(floor_normal) # > 0 si va hacia el suelo
		# Ángulo entre la dirección de movimiento y la normal del piso
		var impact_alignment := 0.0
		if vel.length() > 0.01:
			var dir := vel.normalized()
			impact_alignment = clamp(-dir.dot(floor_normal), -1.0, 1.0)
		# Alineación entre la tabla (forward del player) y la velocidad horizontal
		var board_angle_deg := 0.0
		if horiz_speed > 0.05:
			var forward := -player_owner.transform.basis.z
			forward.y = 0.0
			if !forward.is_zero_approx():
				forward = forward.normalized()
				var move_dir := horiz_vel.normalized()
				var dot_f: float = clamp(forward.dot(move_dir), -1.0, 1.0)
				board_angle_deg = rad_to_deg(acos(dot_f))
		var hard_impact := impact_speed > player_owner.FALL_MIN_IMPACT_SPEED \
			and impact_alignment > player_owner.FALL_MIN_IMPACT_DOT
		var side_landing := horiz_speed > player_owner.FALL_MIN_LANDING_SPEED \
			and board_angle_deg > player_owner.FALL_MAX_BOARD_ANGLE_DEG
		if hard_impact or side_landing:
			var knock_dir := horiz_vel.normalized() if horiz_speed > 0.1 else -floor_normal
			state_machine.transition_to("Fallen", {"knockback": knock_dir})
		else:
			# Aterrizaje limpio: enderezamos el modelo pero mantenemos dirección y velocidad
			if player_owner.has_method("straighten_after_landing"):
				player_owner.straighten_after_landing()
			state_machine.transition_to("Idle")
	
#func sm_physics_process(delta: float) -> void:
	#var vel := player_owner.velocity
	## Mantenemos la trayectoria horizontal que tenía al despegar
	#vel.x = locked_horizontal_velocity.x
	#vel.z = locked_horizontal_velocity.z
	## habilita rotaciones en el aire (solo visuales)
	#if allow_air_rotation and player_owner.on_board and not player_owner.player_is_tricking:
		#var yaw_axis := Input.get_axis("left", "right")    # A/D
		#var pitch_axis := Input.get_axis("up", "down")     # W/S
#
		#var yaw_speed := 240.0    # grados por segundo
		#var pitch_speed := 240.0  # grados por segundo
		#if abs(yaw_axis) > 0.01 or abs(pitch_axis) > 0.01:
			#var yaw_deg := -yaw_axis * yaw_speed * delta      
			#var pitch_deg := pitch_axis * pitch_speed * delta # front/back flip
			#player_owner.apply_air_rotation(yaw_deg, pitch_deg)
	## Gravedad (solo afecta Y)
	#var g := player_owner.GRAVITY
	#if vel.y < 0.0:
		#g *= 1.0  # caída un poco más fuerte
	#vel.y -= g
	#player_owner.velocity = vel
	#player_owner.move_and_slide()

func sm_physics_process(delta: float) -> void:
	var vel := player_owner.velocity
	var horiz := Vector3(vel.x, 0.0, vel.z)
	if player_owner.on_board:
		# --- EN PATINETA: CONTROL EN EL AIRE TIPO "FPS" PERO CON LA CÁMARA ---
		# Velocidad base = con la que despegó
		var base_speed := locked_horizontal_velocity.length()
		if base_speed < 0.1:
			base_speed = player_owner.WALK_SPEED_BOARDING
		# Input tipo FPS (WASD)
		var input_vec := Input.get_vector("left", "right", "up", "down")
		var direction := Vector3.ZERO
		if input_vec != Vector2.ZERO:
			# Igual que en tu script base:
			# var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			direction = (player_owner.head.global_transform.basis
				* Vector3(input_vec.x, 0.0, input_vec.y)).normalized()
			direction.y = 0.0
		if direction != Vector3.ZERO:
			# En el aire: giramos y aceleramos hacia esa dirección manteniendo la velocidad base
			horiz.x = lerp(horiz.x, direction.x * base_speed, delta * 3.0)
			horiz.z = lerp(horiz.z, direction.z * base_speed, delta * 3.0)
		else:
			# Sin input: seguimos más o menos con la velocidad del salto
			horiz.x = lerp(horiz.x, locked_horizontal_velocity.x, delta * 1.0)
			horiz.z = lerp(horiz.z, locked_horizontal_velocity.z, delta * 1.0)
		# Hacemos que la patineta mire hacia donde se mueve
		var move_dir := Vector3(horiz.x, 0.0, horiz.z)
		if move_dir.length() > 0.05 and player_owner.skate:
			player_owner.skate.look_at(
				player_owner.skate.global_transform.origin + move_dir,
				Vector3.UP
			)
	else:
		# --- A PIE: mantenemos la trayectoria con la que entró al salto ---
		horiz = locked_horizontal_velocity
	# Aplicamos la parte horizontal
	vel.x = horiz.x
	vel.z = horiz.z
	# (Opcional) trucos visuales en el aire, si ya los tenías
	if allow_air_rotation and player_owner.on_board and not player_owner.player_is_tricking:
		var yaw_axis := Input.get_axis("left", "right")    # A/D
		var pitch_axis := Input.get_axis("up", "down")     # W/S
		var yaw_speed := 180.0
		var pitch_speed := 180.0
		if abs(yaw_axis) > 0.01 or abs(pitch_axis) > 0.01:
			var yaw_deg := -yaw_axis * yaw_speed * delta
			var pitch_deg := pitch_axis * pitch_speed * delta
			player_owner.apply_air_rotation(yaw_deg, pitch_deg)
	# --- GRAVEDAD (igual que venías usando) ---
	var g := player_owner.GRAVITY
	if vel.y < 0.0:
		g *= 1.0
	vel.y -= g
	player_owner.velocity = vel
	player_owner.move_and_slide()

var trick_tween: Tween = null

func sm_input(event: InputEvent) -> void:
	if not allow_air_rotation:
		return
	if Input.is_action_just_pressed("jump") and not player_owner.is_on_floor():
		if trick_tween != null and trick_tween.is_valid() and trick_tween.is_running():
			return
		player_owner.player_is_tricking = true
		var pop_shovit = player_owner.skate.rotation_degrees + Vector3(0.0, 180.0, 0.0)
		var backflip  = player_owner.skate.rotation_degrees + Vector3(0.0, 0.0, 360.0)
		
		trick_tween = get_tree().create_tween()
		trick_tween.tween_property(player_owner.skate,"rotation_degrees",
				[pop_shovit, backflip].pick_random(),0.4)
		# Cuando termina, reset flag y ref
		trick_tween.finished.connect(_on_trick_tween_finished)

func _on_trick_tween_finished() -> void:
	player_owner.player_is_tricking = false
	trick_tween = null

#func sm_enter(msg: Dictionary) -> void:
	#locked_horizontal_velocity = Vector3(player_owner.velocity.x, 0.0, player_owner.velocity.z)
	## Esta variable permite rotaciones/trucos en el aire
	#allow_air_rotation = msg.get("allow_air_rotation", false)
	#if msg.has("doJump"):
		#print("inAir - ", player_owner.jump_velocity)
		#if GameManager.player_on_powerslide:
			#player_owner.jump_velocity = 10
		## Fuerza de salto basada en la carga
		#var jump_force: float = clamp(
			#player_owner.jump_velocity,
			#player_owner.MIN_JUMP_VELOCITY,
			#player_owner.MAX_JUMP_VELOCITY
		#)
		#player_owner.jump_velocity = 0.0
		#player_owner.velocity.y = jump_force
		#GameManager._update_jumping_pos(player_owner.global_position)
		#player_owner.jump_start.play()

func sm_enter(msg: Dictionary) -> void:
	var vel := player_owner.velocity
	# Guardamos la velocidad horizontal con la que despegó
	locked_horizontal_velocity = Vector3(vel.x, 0.0, vel.z)
	# (si usás esto para trucos, lo podés seguir usando)
	allow_air_rotation = msg.get("allow_air_rotation", false)
	# Salto vertical
	if msg.has("doJump"):
		if GameManager.player_on_powerslide:
			player_owner.jump_velocity = 10
		var jump_force: float = clamp(
			player_owner.jump_velocity,
			player_owner.MIN_JUMP_VELOCITY,
			player_owner.MAX_JUMP_VELOCITY
		)
		player_owner.jump_velocity = 0.0
		player_owner.velocity.y = jump_force
		GameManager._update_jumping_pos(player_owner.global_position)
		player_owner.jump_start.play()
