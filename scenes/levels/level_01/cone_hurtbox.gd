extends MeshInstance3D

@onready var area_3d: Area3D = $Area3D
@export var player: CharacterBody3D
@onready var level_01: Node3D = $"../.."

func _ready() -> void:
	area_3d.body_entered.connect(_on_area_body_entered)

func _on_area_body_entered(body: Node3D) -> void:
	if body != player:
		return
	
	# Asegurarse de que el player viene cayendo
	if not (body is CharacterBody3D):
		return
		
	var player_body := body as CharacterBody3D
	if player_body.velocity.y >= 0.0:
		return  # no viene desde arriba, ignorar
	
	# Rebote del jugador hacia arriba
	player_body.velocity.y = 10.0
	
	level_01.cone_hits_count += 1
	if(level_01.cone_hits_count >= 3):
		GameManager.emit_ready_for_next_level()
