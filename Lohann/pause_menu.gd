extends CanvasLayer

var paused = false

func pause_unpaused():
	paused = !paused

	if paused:
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		show()
	else:
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		hide()

func _input(event):
	if event.is_action_pressed("pause"):
		pause_unpaused()
