extends CharacterBody3D

# Player created from this tutorial:
# https://www.youtube.com/watch?v=A3HLeyaBCq4&list=PLQZiuyZoMHcgqP-ERsVE4x4JSFojLdcBZ&index=1&t=2s

var speed: float
var on_floor: bool

const WALK_SPEED = 3.0
const SPRINT_SPEED = 8.0
const MAX_JUMP_VELOCITY = 7.0
const MIN_JUMP_VELOCITY = 1.0
const SENSITIVITY_X = 0.003
const SENSITIVITY_Y = 0.0025
var jump_velocity: float = 0.0 # Jump force
var jump_charge_velocity: float = 8.0

# Bob variables
const BOB_FREQ: float = 2.0
const BOB_AMP: float = 0.08
var t_bob: float = 0.0

# Fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var skate: Node3D = $Skate
@onready var health_lbl: Label = $CanvasLayer/HealthLbl
@onready var health_component: Node = $HealthComponent
@onready var animation_player: AnimationPlayer = $CanvasLayer/AnimationPlayer

# Audios
@onready var moving: AudioStreamPlayer3D = $Sfx/Moving
@onready var jump_start: AudioStreamPlayer3D = $Sfx/JumpStart
@onready var jump_end: AudioStreamPlayer3D = $Sfx/JumpEnd
@onready var slide_start: AudioStreamPlayer3D = $Sfx/SlideStart
@onready var slide_mid: AudioStreamPlayer3D = $Sfx/SlideMid
@onready var slide_end: AudioStreamPlayer3D = $Sfx/SlideEnd
@onready var rotate: AudioStreamPlayer3D = $Sfx/Rotate

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY_Y)
		camera.rotate_x(-event.relative.y * SENSITIVITY_X)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _process(_delta: float) -> void:
	health_lbl.text = str(health_component.health)

func _physics_process(delta: float) -> void:
	# Add the gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump
	if Input.is_action_pressed("jump") and is_on_floor():
		jump_velocity += jump_charge_velocity * delta
	if Input.is_action_just_released("jump") and is_on_floor():
		if GameManager.player_on_powerslide: jump_velocity = 10
		velocity.y = clamp(jump_velocity, MIN_JUMP_VELOCITY, MAX_JUMP_VELOCITY)
		jump_velocity = 0.0
		GameManager._update_jumping_pos(global_position)
		on_floor = false
		jump_start.play()
		
	# Handle landing
	elif not on_floor and is_on_floor():
		GameManager._update_landing_pos(global_position)
		on_floor = true
		jump_end.play()
		if GameManager.debug:
			drawn_line(GameManager.jumping_pos, GameManager.landing_pos)
	
	
	# Handle Trick
	if Input.is_action_just_pressed("jump") and !is_on_floor():
		var tween = get_tree().create_tween()
		var pop_shovit = skate.rotation_degrees + Vector3(0.0, 180.0, 0.0)
		var backflip = skate.rotation_degrees + Vector3(0.0, 0.0, 360.0)
		tween.tween_property(skate, "rotation_degrees",[pop_shovit, backflip].pick_random(), 0.4)
		tween.play()

	# Handle speed
	if is_on_floor():
		if Input.is_action_pressed("sprint"):
			speed = SPRINT_SPEED
			moving.pitch_scale= 1.2
		else:
			speed = WALK_SPEED
			moving.pitch_scale= 1.0
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor() and not GameManager.player_on_powerslide:
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	# Add sound to skating
	if is_on_floor() and velocity != Vector3.ZERO and !moving.is_playing():
		moving.play()
	elif (not is_on_floor()) or (direction == Vector3.ZERO):
		moving.stop()
	
	# Head Bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	# Orientar el skate según la velocidad horizontal
	var move_dir := Vector3(velocity.x, 0.0, velocity.z)
	if move_dir.length() > 0.05:
		skate.look_at(skate.global_transform.origin + move_dir, Vector3.UP)
	
	move_and_slide()

func _headbob(time: float) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func on_damage(damage):
	animation_player.play("hit")

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
