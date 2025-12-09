class_name PlayerTest
extends CharacterBody3D

# Player created from this tutorial:
# https://www.youtube.com/watch?v=A3HLeyaBCq4&list=PLQZiuyZoMHcgqP-ERsVE4x4JSFojLdcBZ&index=1&t=2s

var speed: float
var on_floor: bool
var player_fall_off: bool = false
var player_is_tricking: bool = false
var player_on_skate: bool = true
var skate_on_inventory: bool = true

const WALK_SPEED = 3.0
const SPRINT_SPEED = 8.0
const SENSITIVITY_X = 0.003
const SENSITIVITY_Y = 0.0025

var input_direction := Vector3.ZERO
var is_running := false
const JUMP_VELOCITY = 20.
const MOUSE_SENSITIVITY := .08
const FRICTION := .1
const GRAVITY := 0.75

# Bob variables
const BOB_FREQ: float = 2.0
const BOB_AMP: float = 0.08
var t_bob: float = 0.0

# Fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5
var delta_pysics: float
var delta_process: float

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var skate: Node3D = $Skate
@onready var health_lbl: Label = $CanvasLayer/HealthLbl
@onready var health_component: Node = $HealthComponent
@onready var animation_player: AnimationPlayer = $CanvasLayer/AnimationPlayer
@onready var mesh: MeshInstance3D = $MeshInstance3D

# Shake variables:
@onready var shaker: Node3D = $Head/Shaker
@export var fall_off_shake_intensity: float = 3.0
@export var fall_off_shake_duration: float = 1.5
@export var hitted_shake_intensity: float = 1.0
@export var hitted_shake_duration: float = 0.5

# Audios
@onready var moving: AudioStreamPlayer3D = $Sfx/Moving
@onready var jump_start: AudioStreamPlayer3D = $Sfx/JumpStart
@onready var jump_end: AudioStreamPlayer3D = $Sfx/JumpEnd
@onready var slide_start: AudioStreamPlayer3D = $Sfx/SlideStart
@onready var slide_mid: AudioStreamPlayer3D = $Sfx/SlideMid
@onready var slide_end: AudioStreamPlayer3D = $Sfx/SlideEnd
@onready var rotate: AudioStreamPlayer3D = $Sfx/Rotate

@export var player_state_machine: StateMachinePlayer

#Variables SOBRE la patineta
var on_board := false
const WALK_SPEED_BOARDING := 5.0
const SPRINT_SPEED_BOARDING := 12.0
var has_board_equipped: bool = true 
var ignore_jump_once: bool = false

const SKATE_MAX_FLAT_SPEED := 10.0         # Velocidad maxima sin sprint
const SKATE_MAX_SPRINT_SPEED := 16.0       # Velocidad maxima haciendo push
const SKATE_PUSH_ACCEL := 22.0             # Velocidad del sprint arriba de patineta
const SKATE_ROLL_FRICTION := 4.0           # Que tan rápido pierde velocidad en plano
const SKATE_SLOPE_ACCEL := 30.0            # Fuerza de frenado a lo largo de la rampa
const SKATE_MAX_PUSH_SLOPE_DEG := 20.0     # Ángulo máximo de rampa donde tiene sentido empujar

# Variables de SALTO
const MAX_JUMP_VELOCITY = 30.0
const MIN_JUMP_VELOCITY = 1.0
var jump_velocity: float = 5.0 # Jump force
var jump_charge_velocity: float = 5.0

#variables para gestionar caida
const FALL_MIN_IMPACT_SPEED := 25.0 		#qué tan fuerte tenés caer para considerar un impacto duro.
const FALL_MIN_IMPACT_DOT := 0.7 			#qué tanto alineada la velocidad con la normal del suelo (si cae muy “de frente” al piso)
const FALL_MIN_LANDING_SPEED := 12.0		#velocidad mínima para que importe el ángulo de la tabla.
const FALL_MAX_BOARD_ANGLE_DEG := 65.0		#si cae muy de costado (perpendicular a la dirección real de movimiento), se considera caída.

# inclinación para habilitar trucos en el aire
const TRICK_MIN_SLOPE_DEG := 12.0  

#escena que se instancia cuando te caes
@export var skate_world_scene: PackedScene

func _ready() -> void:
	skate.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func equip_board() -> void:
	has_board_equipped = true

func unequip_board() -> void:
	has_board_equipped = false

func _update_skate_visual() -> void:
	skate.visible = false

func spawn_world_board() -> void:
	if skate_world_scene == null:
		return
	var board_instance := skate_world_scene.instantiate()
	board_instance.global_transform = global_transform
	#if board_instance.has_variable("player_owner"):
		#board_instance.player_owner = self
	if board_instance is RigidBody3D:
		var forward := -transform.basis.z
		board_instance.linear_velocity = forward * 5.0
	get_tree().current_scene.add_child(board_instance)


func fall_from_board() -> void:
	# Llamado desde un estado de skate cuando te caés
	if not on_board:
		return
	on_board = false
	has_board_equipped = false
	_update_skate_visual()
	spawn_world_board()


func obtain_world_board() -> void:
	# El jugador vuelve a tener la tabla disponibl
	has_board_equipped = true
	print("Patineta recogida. has_board_equipped = ", has_board_equipped)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# --- MOUSE LOOK ---
		if on_board:
			# Arriba de la patineta:
			#   - el mouse SOLO mueve la cabeza/cámara (free look)
			head.rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
			if player_state_machine.state.name != "InAir":
				camera.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY))
				camera.rotation.x = clamp(
					camera.rotation.x,
					deg_to_rad(-60),
					deg_to_rad(60)
				)
		else:
			# A pie (walk / sprint):
			#   - el mouse rota el CUERPO solo cuando NO está en el aire
			if player_state_machine.state.name != "InAir":
				rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
				camera.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY))
				camera.rotation.x = clamp(
					camera.rotation.x,
					deg_to_rad(-60),
					deg_to_rad(60)
				)
	# --- DIRECCIÓN DE MOVIMIENTO (WASD) ---
	input_direction = Vector3.ZERO
	input_direction.x = Input.get_axis("left", "right")
	input_direction.z = Input.get_axis("up", "down")
	input_direction = input_direction.rotated(Vector3.UP, rotation.y).normalized()
	# --- SALTO / SPRINT como ya lo tenías ---
	if Input.is_action_pressed("jump") and is_on_floor():
		jump_velocity += jump_charge_velocity
	if Input.is_action_just_pressed("sprint"):
		is_running = !is_running
	if Input.is_action_just_released("sprint"):
		is_running = false



func get_slope_data() -> Dictionary:
	if !is_on_floor():
		return {
			"angle_deg": 0.0,
			"normal": Vector3.UP,
			"tangent": Vector3.ZERO
		}
	var n: Vector3 = get_floor_normal()
	var dot_up: float = clamp(n.dot(Vector3.UP), -1.0, 1.0)
	var angle_rad := acos(dot_up)
	var angle_deg := rad_to_deg(angle_rad)
	# proyectar la gravedad sobre el plano de la rampa
	var gravity_vec := Vector3.DOWN * GRAVITY
	var tangent := gravity_vec - n * gravity_vec.dot(n)
	if !tangent.is_zero_approx():
		tangent = tangent.normalized()
	
	return {
		"angle_deg": angle_deg,
		"normal": n,
		"tangent": tangent
	}

func reset_air_rotation() -> void:
	# El cuerpo físico: solo debe estar "derecho" (sin inclinarse)
	#    Mantenemos el yaw (rotación Y) para no cambiar la dirección de movimiento
	var body_rot := rotation_degrees
	body_rot.x = 0.0
	body_rot.z = 0.0
	rotation_degrees = body_rot
	# Parte visual: que no tenga ningún offset raro respecto al cuerpo
	if mesh:
		mesh.rotation_degrees = Vector3.ZERO
	if head:
		head.rotation_degrees = Vector3.ZERO
	if skate:
		skate.rotation_degrees = Vector3.ZERO
	# Cámara: que mire "de frente" localmente (sin yaw/roll extra)
	# Después el jugador puede volver a mirar con el mouse como siempre.
	if camera:
		var cam_rot := camera.rotation_degrees
		cam_rot.y = 0.0
		cam_rot.z = 0.0
		# el pitch (x) lo dejamos como esté, o si querés forzarlo a 0:
		# cam_rot.x = 0.0
		camera.rotation_degrees = cam_rot

func straighten_after_landing() -> void:
	# Enderezar el cuerpo (sin inclinaciones raras)
	var body_rot := rotation_degrees
	body_rot.x = 0.0
	body_rot.z = 0.0
	# La dirección de movimiento manda: si hay velocidad horizontal, orientamos el cuerpo hacia ahí
	var horiz_vel := Vector3(velocity.x, 0.0, velocity.z)
	if horiz_vel.length() > 0.05:
		var target_yaw := atan2(-horiz_vel.x, -horiz_vel.z)
		body_rot.y = rad_to_deg(target_yaw)  # importante: en grados porque usamos rotation_degrees
	rotation_degrees = body_rot
	# Parte visual: sin inclinación, pero heredando el yaw del cuerpo
	if mesh:
		var mrot := mesh.rotation_degrees
		mrot.x = 0.0
		mrot.z = 0.0
		mrot.y = 0.0  # yaw en 0 local → mira como el cuerpo
		mesh.rotation_degrees = mrot
	if head:
		var hrot := head.rotation_degrees
		hrot.x = 0.0
		hrot.z = 0.0
		hrot.y = 0.0
		head.rotation_degrees = hrot
	if skate:
		var srot := skate.rotation_degrees
		srot.x = 0.0
		srot.z = 0.0
		srot.y = 0.0   # yaw local 0 → se alinea con el cuerpo
		skate.rotation_degrees = srot
		# Y además, por si acaso, alineamos explícitamente la tabla a la velocidad
		if horiz_vel.length() > 0.05:
			var dir := horiz_vel.normalized()
			skate.look_at(
				skate.global_transform.origin + dir,
				Vector3.UP
			)
	# Cámara: la dejamos sin roll; el pitch sepuede dejar o resetear
	if camera:
		var cam_rot := camera.rotation_degrees
		cam_rot.z = 0.0
		# si querés que mire de frente también:
		# cam_rot.x = 0.0
		camera.rotation_degrees = cam_rot


func apply_air_rotation(yaw_deg: float, pitch_deg: float) -> void:
	# yaw_deg y pitch_deg están en grados
	var yaw_rad := deg_to_rad(yaw_deg)
	var pitch_rad := deg_to_rad(pitch_deg)
	# YAW (spin sobre eje Y): giramos mesh, cabeza y skate
	if abs(yaw_deg) > 0.001:
		mesh.rotate_y(yaw_rad)
		head.rotate_y(yaw_rad)
		skate.rotate_y(yaw_rad)
	# PITCH (flip adelante/atrás): giramos mesh, cabeza y skate
	if abs(pitch_deg) > 0.001:
		mesh.rotate_x(pitch_rad)
		head.rotate_x(pitch_rad)
		skate.rotate_x(pitch_rad)



func _process(_delta: float) -> void:
	delta_process = _delta
	health_lbl.text = str(health_component.health)

func _physics_process(delta: float) -> void:
	delta_pysics = delta

func _headbob(time: float) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func on_damage(_damage):
	shaker.shake(hitted_shake_duration, hitted_shake_intensity)
	animation_player.play("hit")

func on_fall_off() -> void:
	pass

func on_death() -> void:
	get_tree().quit()


#################
# DEBUG FUNCTIONS
func drawn_line(pos1: Vector3, pos2: Vector3, color = Color.WHITE_SMOKE, persist_ms = 0):
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()

	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(pos1)
	immediate_mesh.surface_add_vertex(pos2)
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color

	return await final_cleanup(mesh_instance, persist_ms)
	
func final_cleanup(mesh_instance: MeshInstance3D, persist_ms: float):
	get_tree().get_root().add_child(mesh_instance)
	if persist_ms == 1:
		await get_tree().physics_frame
		mesh_instance.queue_free()
	elif persist_ms > 0:
		await get_tree().create_timer(persist_ms).timeout
		mesh_instance.queue_free()
	else:
		return mesh_instance
