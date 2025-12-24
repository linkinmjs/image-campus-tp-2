extends CanvasLayer

@onready var control: Control = $Control

func _ready() -> void:
	GameManager.player_skillcheck_toggled.connect(_on_skillcheck_toggled)

func _physics_process(delta: float) -> void:
	pass

func _on_skillcheck_toggled() -> void:
	print("skillcheck toggled")
	if GameManager.powerslide_skillcheck_active:
		control.show()
	else:
		control.hide()
