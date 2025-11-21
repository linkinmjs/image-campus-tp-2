extends Node

@onready var start_button: Button = $CanvasLayer/Control/Main/StartButton
@onready var options_button: Button = $CanvasLayer/Control/Main/OptionsButton
@onready var quit_button: Button = $CanvasLayer/Control/Main/QuitButton
@onready var back_button: Button = $CanvasLayer/Control/Options/BackButton


@onready var main: VBoxContainer = $CanvasLayer/Control/Main
@onready var options: VBoxContainer = $CanvasLayer/Control/Options


func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)

func _on_start_button_pressed() -> void:
	pass
	
func _on_options_button_pressed() -> void:
	main.hide()
	options.show()

func _on_back_button_pressed() -> void:
	options.hide()
	main.show()
	
func _on_quit_button_pressed() -> void:
	get_tree().quit()
