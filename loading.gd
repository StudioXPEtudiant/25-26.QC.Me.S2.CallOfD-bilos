extends CanvasLayer

@onready var logo = $TextureRect

func _ready():
	logo.pivot_offset = logo.size / 2

func _process(delta):
	logo.rotation_degrees += delta * 120.0

func start_loading(path):
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file(path)
	queue_free()
