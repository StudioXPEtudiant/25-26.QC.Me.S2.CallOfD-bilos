extends Label

func _ready():
	text = "+1"
	visible = true
	modulate.a = 1.0

	await get_tree().create_timer(1.0).timeout
	queue_free()

func _process(delta):
	position.y -= 40 * delta
	modulate.a -= delta
