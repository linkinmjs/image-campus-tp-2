extends PlayerState
#INAIR

func sm_ready() -> void:
	pass

func sm_process(delta: float) -> void:
	if player_owner.is_on_floor():
		state_machine.transition_to("Idle")

func sm_physics_process(delta: float) -> void:

	player_owner.velocity.y -= player_owner.GRAVITY
	player_owner.move_and_slide()
#
#func sm_input(event: InputEvent) -> void:
	#if Input.is_action_pressed("jump") and !player_owner.is_on_floor():
		#player_owner.player_is_tricking = true
		#var tween = get_tree().create_tween()
		#
		#var pop_shovit = player_owner.skate.rotation_degrees + Vector3(0.0, 180.0, 0.0)
		#var backflip = player_owner.skate.rotation_degrees + Vector3(0.0, 0.0, 360.0)
		#tween.tween_property(player_owner.skate, "rotation_degrees",[pop_shovit, backflip].pick_random(), 0.4)
		#if !tween.is_running():
			#tween.play()
		#player_owner.player_is_tricking = false

var trick_tween: Tween = null

func sm_input(event: InputEvent) -> void:
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

func sm_enter(msg: Dictionary) -> void:
	if msg.has("doJump"):
		#player_owner.velocity.y = 0
		#player_owner.velocity.y += player_owner.JUMP_VELOCITY
		print("inAir - ", player_owner.jump_velocity)
		if GameManager.player_on_powerslide: player_owner.jump_velocity = 10
		player_owner.velocity.y = clamp(player_owner.jump_velocity, player_owner.MIN_JUMP_VELOCITY, player_owner.MAX_JUMP_VELOCITY)
		player_owner.jump_velocity = 0.0
		GameManager._update_jumping_pos(player_owner.global_position)
		player_owner.jump_start.play()
