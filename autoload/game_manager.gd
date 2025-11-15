extends Node

var last_point_before_jump: Vector3

func _update_last_point_before_jump(global_position: Vector3) -> void:
	last_point_before_jump = global_position
