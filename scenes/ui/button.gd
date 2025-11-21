extends Button

# TODO: mejorar la dirección de los audios
@onready var audio_button_move: AudioStreamPlayer = $"../../../../AudioButtonMove"
@onready var audio_button_select: AudioStreamPlayer = $"../../../../AudioButtonSelect"
@onready var audio_button_select_with_zombie: AudioStreamPlayer = $"../../../../AudioButtonSelectWithZombie"

@export var is_start_button: bool = false
@export var is_quit_button: bool = false
var still_hovered: bool = false

func _ready() -> void:
	button_down.connect(_on_button_down)

func _process(_delta: float) -> void:
	if is_hovered() and still_hovered:
		return
	
	if is_hovered() and not still_hovered:
		audio_button_move.play()
		still_hovered = true
	else:
		still_hovered = false

func _on_button_down() -> void:
	if is_quit_button:
		pass
	elif is_start_button:
		audio_button_select_with_zombie.play()
	else:
		audio_button_select.play()
