extends RigidBody3D

@onready var pickup_area: Area3D = $Area3D

var player_owner: PlayerTest = null

func _ready() -> void:
	# Conectar las señales del área
	if pickup_area:
		pickup_area.body_entered.connect(_on_body_entered)
		pickup_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body is PlayerTest:
		player_owner = body
		# acá podrías mostrar una interfaz "E para agarrar patineta"

func _on_body_exited(body: Node3D) -> void:
	if body == player_owner:
		player_owner = null
		# ocultar interfaz de interacción si lo tenías

func _process(delta: float) -> void:
	if player_owner and Input.is_action_just_pressed("interact"):
		_pickup()

func _pickup() -> void:
	if player_owner and player_owner.has_method("obtain_world_board"):
		player_owner.obtain_world_board()
	queue_free()
