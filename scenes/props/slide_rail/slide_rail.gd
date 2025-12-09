@tool
extends Node3D

@onready var start: Marker3D = $Start
@onready var end: Marker3D = $End
@onready var rail: MeshInstance3D = $Rail
@onready var area_3d: Area3D = $Rail/Area3D

@onready var path_3d: Path3D = $Path3D
@onready var path_follow_3d: PathFollow3D = $Path3D/PathFollow3D
@onready var marker_3d: Marker3D = $Path3D/PathFollow3D/Marker3D

@export var slide_speed: float = 8.0  # unidades/seg


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

	

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if not player_on_barrier or not path_follow_3d or not marker_3d:
		return
	
	# Largo real del path (en unidades del mundo)
	var baked_length := path_3d.curve.get_baked_length()
	if baked_length <= 0.0:
		return

	# Velocidad sobre el ratio, en función del largo del rail
	var progress_speed := slide_speed / baked_length

	path_follow_3d.progress_ratio = clamp(
		path_follow_3d.progress_ratio + slide_dir * progress_speed * delta,
		0.0,
		1.0
	)
	
	# Chequear si llegó al final del path
	if path_follow_3d.progress_ratio <= 0.0 or path_follow_3d.progress_ratio >= 1.0:
		_detach_player()
		return
	
	player.global_position = marker_3d.global_position

func _unhandled_input(event: InputEvent) -> void:
	if not player_on_barrier:
		return
	
	if event.is_action_pressed("jump"):
		_jump_off()

func _jump_off() -> void:
	if player == null:
		return
	
	# Tangente base del riel en la posición actual
	var base_tangent := -path_follow_3d.global_transform.basis.z
	
	# Ajustar según la dirección real del slide (slide_dir puede ser 1 o -1)
	var tangent := (base_tangent * slide_dir).normalized()
	
	# Velocidad de lanzamiento: un poco hacia adelante + hacia arriba
	var launch_speed_forward := 6.0
	var launch_speed_up := 5.0
	var launch_velocity := tangent * launch_speed_forward + Vector3.UP * launch_speed_up
	
	# Aplicamos la velocidad al player
	player.velocity = launch_velocity
	
	# Lo levantamos un poco para sacarlo del Area3D y evitar que quede pegado
	player.global_position += Vector3.UP * 0.3
	
	_detach_player()


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
	if player_on_barrier:
		return


	player_on_barrier = true
	GameManager.player_on_powerslide = true
	GameManager._toggle_player_skillchecked()
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
	GameManager._toggle_player_skillchecked()
	player = null
