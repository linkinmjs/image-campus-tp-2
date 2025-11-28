@tool
extends Node3D

@onready var start: Marker3D = $Start
@onready var end: Marker3D = $End
@onready var rail: MeshInstance3D = $Rail
@onready var area_3d: Area3D = $Rail/Area3D

@onready var path_3d: Path3D = $Path3D
@onready var path_follow_3d: PathFollow3D = $Path3D/PathFollow3D
@onready var marker_3d: Marker3D = $Path3D/PathFollow3D/Marker3D


var slide_dir := 1.0
var player_on_barrier: bool
var player: CharacterBody3D

func _ready() -> void:
	player_on_barrier = false
	area_3d.body_entered.connect(_on_body_entered)
	area_3d.body_exited.connect(_on_body_exited)
	
func _process(delta: float) -> void:
	# Posiciones de los dos extremos
	var a: Vector3 = start.global_position
	var b: Vector3 = end.global_position
	
	var dir: Vector3 = b - a
	var length := dir.length()
	var mid := a + dir * 0.5
	
	var curve := path_3d.curve
	
	# Pasamos las posiciones globales de los Marker3D
	# a coordenadas locales del Path3D
	var p0: Vector3 = path_3d.to_local(a)
	var p1: Vector3 = path_3d.to_local(b)
	
	curve.clear_points()
	curve.add_point(p0)
	curve.add_point(p1)

	# Orientar cilindro:
	var up := dir.normalized() # eje Y del tubo
	#print("up = dir.normalized()    >>    %s" % up)
	var side := up.cross(Vector3.FORWARD) # eje X provisional
		
	side = side.normalized()
	var forward := side.cross(up).normalized() # eje Z
	
	var basis := Basis(side, up, forward)      # x = side, y = up, z = forward

	# Colocamos y orientamos el tubo
	rail.global_transform = Transform3D(basis, mid)
	
	# Ajustar largo del cilindro:
	# CylinderMesh tiene altura 2 por defecto, así que:
	# altura_final = 2 * scale.y  =>  scale.y = length / 2
	rail.scale = Vector3(1.0, length * 0.5, 1.0)
	
	# A partir de acá manejamos la lógica del powerslide
	if player_on_barrier and path_follow_3d.progress_ratio < 1:
		path_follow_3d.progress_ratio += slide_dir * 0.2 * delta
		player.global_position = marker_3d.global_position
	
	
	
func _on_body_entered(body: CharacterBody3D) -> void:
	print("enter")
	if player_on_barrier:
		return
	player_on_barrier = true
	GameManager.player_on_powerslide = true
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



func _on_body_exited(_body: CharacterBody3D) -> void:
	print("exit")
	player_on_barrier = false
	GameManager.player_on_powerslide = false
	player = null
