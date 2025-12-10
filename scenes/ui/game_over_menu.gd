extends Node

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_select"):
		get_tree().change_scene_to_file("res://scenes/game.tscn")
