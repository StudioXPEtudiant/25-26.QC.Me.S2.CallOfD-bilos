extends CanvasLayer

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta):
	if get_tree().current_scene.name != "World":
		return

	if Input.is_action_just_pressed("pause"):
		visible = !visible
		get_tree().paused = visible
		
		var crosshair = get_tree().get_current_scene().find_child("Crosshair", true, false)
		if crosshair:
			crosshair.visible = !visible
		
		if visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_settings_button_pressed():
	var settings = load("res://Settings.tscn").instantiate()
	get_tree().root.add_child(settings)
	settings.process_mode = Node.PROCESS_MODE_ALWAYS
