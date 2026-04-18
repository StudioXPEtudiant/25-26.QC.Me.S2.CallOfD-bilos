extends Camera3D

var player

func _ready():
	player = get_tree().get_current_scene().find_child("Player", true, false)

func _process(delta):
	if player:
		global_position.x = player.global_position.x
		global_position.z = player.global_position.z
