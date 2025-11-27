class_name PlayerState
extends StateSM

var player_owner : PlayerTest

func _ready() -> void:
	await owner.ready
	player_owner = owner.player as PlayerTest
	assert(player_owner != null, "La variable player no funciona, [PlayerState - func _ready] ")
	
	
