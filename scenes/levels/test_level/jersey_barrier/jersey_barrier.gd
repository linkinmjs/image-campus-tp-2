extends Node3D

@onready var area_3d: Area3D = $Path3D/Area3D
@onready var collision_shape_3d: CollisionShape3D = $Path3D/Area3D/CollisionShape3D
@onready var path_follow_3d: PathFollow3D = $Path3D/PathFollow3D
@onready var path_3d: Path3D = $Path3D
@onready var marker_3d: Marker3D = $Path3D/PathFollow3D/Marker3D

@export var player_parent_node: Node3D

var slide_dir := 1.0
var player_on_barrier: bool
var player: CharacterBody3D

func _ready() -> void:
	player_on_barrier = false
	area_3d.body_entered.connect(on_body_connected)
	area_3d.body_exited.connect(on_body_exited)

func _process(delta: float) -> void:
	if player_on_barrier and path_follow_3d.progress_ratio < 1:
		path_follow_3d.progress_ratio += slide_dir * 0.2 * delta
		player.global_position = marker_3d.global_position
		
func on_body_exited(_body: CharacterBody3D) -> void:
	player_on_barrier = false
	player = null
	
func on_body_connected(body: CharacterBody3D) -> void:
	if player_on_barrier:
		return
	player_on_barrier = true
	player = body
	
	var closest_offset = path_3d.curve.get_closest_offset(path_3d.to_local(body.global_position))
	var backed_length = path_3d.curve.get_baked_length()
	var new_progress_ration = closest_offset / backed_length
	
	path_follow_3d.progress_ratio = new_progress_ration
	
	# Tangente del path donde cayó el player
	# (PathFollow apunta "forward" en -Z de su basis)
	var tangent := -path_follow_3d.global_transform.basis.z
	
	# Velocidad horizontal del player al entrar
	var v := body.velocity
	v.y = 0.0
	if v.length() < 0.001:
		# fallback si llegó casi quieto: usa vector desde player hacia la tangente
		v = (path_follow_3d.global_transform.origin - body.global_transform.origin)
		v.y = 0.0

	# Decidir sentido: +1 avanza, -1 retrocede
	slide_dir = 1.0 if v.normalized().dot(tangent.normalized()) >= 0.0 else -1.0
