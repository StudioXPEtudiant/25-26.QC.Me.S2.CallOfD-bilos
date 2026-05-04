extends TextureRect

func _ready():
	visible = get_tree().current_scene.name == "World"
