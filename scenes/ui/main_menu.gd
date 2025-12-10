extends Node
@onready var main_menu: Node = $"."

@onready var start_button: Button = $CanvasLayer/Control/Main/StartButton
@onready var options_button: Button = $CanvasLayer/Control/Main/OptionsButton
@onready var quit_button: Button = $CanvasLayer/Control/Main/QuitButton
@onready var back_button: Button = $CanvasLayer/Control/Options/BackButton

@onready var main: VBoxContainer = $CanvasLayer/Control/Main
@onready var options: VBoxContainer = $CanvasLayer/Control/Options

@onready var scene_transition_helper: CanvasLayer = %SceneTransitionHelper
@export var first_level: PackedScene
@export var pause_menu: PackedScene

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	start_button.pressed.connect(_on_start_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)
	GameManager.screen_totally_black.connect(_on_screen_totally_black)

func _on_start_button_pressed() -> void:
	scene_transition_helper.start_game()
	
func _on_options_button_pressed() -> void:
	main.hide()
	options.show()

func _on_back_button_pressed() -> void:
	options.hide()
	main.show()
	
func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_screen_totally_black() -> void:
	var first_level_instance = first_level.instantiate()
	var pause_menu_instance = pause_menu.instantiate()
	add_sibling(first_level_instance)
	add_sibling(pause_menu_instance)
	queue_free()
