@tool
extends Node3D

@onready var start: Marker3D = $Start
@onready var end: Marker3D = $End
@onready var rail: MeshInstance3D = $Rail
@onready var area_3d: Area3D = $Rail/Area3D


func _ready() -> void:
	area_3d.body_entered.connect(_on_body_entered)
	area_3d.body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	
	# Posiciones de los dos extremos
	var a: Vector3 = start.global_position
	var b: Vector3 = end.global_position

	var dir: Vector3 = b - a
	var length := dir.length()
	
	var mid := a + dir * 0.5
	
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
	
func _on_body_entered(body: Node3D) -> void:
	print("enter")
	print(body.name)


func _on_body_exited(body: Node3D) -> void:
	print("exit")
	print(body.name)
