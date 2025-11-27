extends PlayerState
#CROUCH
#var original_points: PackedVector3Array
#var crouched_points: PackedVector3Array
#
#func sm_ready() -> void:
	#original_points = state_machine.collision_shape_player.shape.points.duplicate()
	#crouched_points = PackedVector3Array()
	#for p in original_points:
		 # “Achatar” en Y (agachado)
		#crouched_points.append(Vector3(p.x, p.y * 0.5, p.z))

func sm_enter(msg: Dictionary) -> void:
	state_machine.camera_3d.position.y = -0.4
	#set_crouch(true)

func sm_process(delta: float) -> void:
	pass

func sm_physics_process(delta: float) -> void:
	player_owner.velocity.x = lerp(player_owner.velocity.x, player_owner.WALK_SPEED * 0.4 * player_owner.input_direction.x, player_owner.FRICTION)
	player_owner.velocity.z = lerp(player_owner.velocity.z, player_owner.WALK_SPEED * 0.4 * player_owner.input_direction.z, player_owner.FRICTION)
	player_owner.velocity.y -= player_owner.GRAVITY
	player_owner.move_and_slide()

func sm_input(event: InputEvent) -> void:
	if Input.is_action_just_released("crouch"):
		state_machine.transition_to("Idle")

func sm_exit() -> void:
	state_machine.camera_3d.position.y = 0
	#set_crouch(false)

#func set_crouch(is_crouching: bool) -> void:
	#var convex := state_machine.collision_shape_player.shape as ConvexPolygonShape3D
	#if is_crouching:
		#convex.points = crouched_points
	#else:
		#convex.points = original_points
