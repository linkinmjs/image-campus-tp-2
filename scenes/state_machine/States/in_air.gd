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

func sm_input(event: InputEvent) -> void:
	pass

func sm_enter(msg: Dictionary) -> void:
	if msg.has("doJump"):
		#player_owner.velocity.y = 0
		player_owner.velocity.y += player_owner.JUMP_VELOCITY
