@tool
extends Node3D

@onready var start: Marker3D = $Start
@onready var end: Marker3D = $End
@onready var rail: MeshInstance3D = $Rail
@onready var area_3d: Area3D = $Rail/Area3D

@onready var path_3d: Path3D = $Path3D
@onready var path_follow_3d: PathFollow3D = $Path3D/PathFollow3D
@onready var marker_3d: Marker3D = $Path3D/PathFollow3D/Marker3D

var slide_dir: float = 1.0
var player_on_barrier: bool = false
var player: CharacterBody3D


func _ready() -> void:
	player_on_barrier = false

	# Preparamos geometría una vez al entrar (editor y juego)
	_update_rail_and_path()

	# Solo conectamos señales cuando estamos en el juego
	if not Engine.is_editor_hint():
		area_3d.body_entered.connect(_on_body_entered)
		area_3d.body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	# En editor y en juego: mantener rail/path sincronizados con Start/End
	_update_rail_and_path()

	# En el editor no hacemos lógica de powerslide
	if Engine.is_editor_hint():
		return

	# Lógica de powerslide
	if player_on_barrier and path_follow_3d and marker_3d:
		var speed := 0.2
		path_follow_3d.progress_ratio = clamp(
			path_follow_3d.progress_ratio + slide_dir * speed * delta,
			0.0,
			1.0
		)
		player.global_position = marker_3d.global_position

func _physics_process(delta: float) -> void:
	if player_on_barrier and path_follow_3d and marker_3d:
		var speed := 0.2
		path_follow_3d.progress_ratio += slide_dir * speed * delta
	
	# Chequear si llegó al final del path
	if path_follow_3d.progress_ratio <= 0.0 or path_follow_3d.progress_ratio >= 1.0:
		_detach_player()
		return
	
	player.global_position = marker_3d.global_position

func _update_rail_and_path() -> void:
	if not start or not end or not rail or not path_3d:
		return

	# Posiciones de los dos extremos
	var a: Vector3 = start.global_position
	var b: Vector3 = end.global_position

	var dir: Vector3 = b - a
	var length := dir.length()
	if length <= 0.001:
		return

	var mid := a + dir * 0.5

	# Actualizar Curve3D del Path3D
	if path_3d.curve == null:
		path_3d.curve = Curve3D.new()
	var curve := path_3d.curve

	var p0: Vector3 = path_3d.to_local(a)
	var p1: Vector3 = path_3d.to_local(b)

	curve.clear_points()
	curve.add_point(p0)
	curve.add_point(p1)

	# Orientar cilindro del rail
	var up := dir.normalized() # eje Y del tubo

	var side := up.cross(Vector3.FORWARD) # eje X provisional
	if side.length() < 0.001:
		side = up.cross(Vector3.RIGHT)
	side = side.normalized()

	var forward := side.cross(up).normalized() # eje Z

	var basis := Basis(side, up, forward)

	# Colocamos y orientamos el tubo
	rail.global_transform = Transform3D(basis, mid)

	# Ajustar largo del cilindro (height = 2 por defecto)
	rail.scale = Vector3(1.0, length * 0.5, 1.0)


func _on_body_entered(body: CharacterBody3D) -> void:
	print(body.name)
	print("enter")
	if player_on_barrier:
		return

	player_on_barrier = true
	GameManager.player_on_powerslide = true
	player = body

	# Calcular posición inicial sobre el path
	var curve := path_3d.curve
	if curve == null:
		return

	var closest_offset := curve.get_closest_offset(path_3d.to_local(body.global_position))
	var baked_length := curve.get_baked_length()
	if baked_length <= 0.0:
		return

	var new_progress_ratio := closest_offset / baked_length
	path_follow_3d.progress_ratio = clamp(new_progress_ratio, 0.0, 1.0)

	# Tangente del path donde cayó el player
	var tangent := -path_follow_3d.global_transform.basis.z

	# Velocidad horizontal del player al entrar
	var v := body.velocity
	v.y = 0.0
	if v.length() < 0.001:
		v = (path_follow_3d.global_transform.origin - body.global_transform.origin)
		v.y = 0.0

	# Decidir sentido del slide
	slide_dir = 1.0 if v.normalized().dot(tangent.normalized()) >= 0.0 else -1.0


func _on_body_exited(body: CharacterBody3D) -> void:
	if body != player:
		return
	_detach_player()

func _detach_player() -> void:
	if not player_on_barrier:
		return
	player_on_barrier = false
	GameManager.player_on_powerslide = false
	player = null
