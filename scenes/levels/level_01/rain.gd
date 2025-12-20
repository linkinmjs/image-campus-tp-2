extends Node3D

@onready var rain_effect_particles_3d: GPUParticles3D = $GPUParticles3D

func _ready() -> void:
	GameManager.rain_stopped.connect(_on_rain_stopped)

func _on_rain_stopped() -> void:
	rain_effect_particles_3d.emitting = false
