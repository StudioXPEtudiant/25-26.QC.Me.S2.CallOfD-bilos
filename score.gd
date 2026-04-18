extends Label

var score = 0

func _ready():
	if get_tree().current_scene.name != "World":
		visible = false

func add_point():
	score += 1
	text = str(score)
