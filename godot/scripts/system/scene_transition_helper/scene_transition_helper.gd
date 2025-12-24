extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func start_game() -> void:
	#print("helper start_game")
	animation_player.play("start_game")

func change_level() -> void:
	print("helper change_level")
	animation_player.play("change_level")

func change_scene() -> void:
	print("helper change_scene")
	GameManager.emit_screen_totally_black()
