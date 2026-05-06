extends Camera3D

var player

func _ready():
	var minimapui = get_parent().find_child("MiniMapUI", true, false)
	if minimapui:
		minimapui.visible = true

	player = get_tree().current_scene.find_child("Player", true, false)

func _process(delta):
	if player:
		global_position.x = player.global_position.x
		global_position.z = player.global_position.z
