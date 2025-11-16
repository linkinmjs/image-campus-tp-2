extends Node

var jumping_pos: Vector3
var landing_pos: Vector3

var player_on_powerslide: bool = false

var debug: bool = true

func _update_jumping_pos(global_position: Vector3) -> void:
	jumping_pos = global_position
	if debug:
		print("jumping_pos: %s" % jumping_pos)

func _update_landing_pos(global_position: Vector3) -> void:
	landing_pos = global_position
	if debug:
		print("landing_pos: %s" % landing_pos)
		_debug_jump_land_vector()

func _debug_jump_land_vector() -> void:
	var last_jump_vec = landing_pos - jumping_pos
	# Opcional:
	# Se puede usar algo como: last_jump_vec.length() > 0.2
	# para evitar "baches"
	print("Aterrizaje en: ", landing_pos, "  Vector salto: ", jumping_pos, "  Dist: ", last_jump_vec.length())

#################
# DEBUG FUNCTIONS
func _toggle_debug() -> void:
	if debug:
		debug = false
	else:
		debug = true
