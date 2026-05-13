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
	var existing = get_tree().root.find_child("Settings", true, false)

	if existing:
		existing.queue_free()

	var settings = load("res://Settings.tscn").instantiate()

	settings.name = "Settings"
	settings.process_mode = Node.PROCESS_MODE_ALWAYS

	get_tree().root.add_child(settings)

	settings.visible = true

func _on_quit_button_pressed():
	get_tree().quit()

func _on_backtomenu_button_pressed():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://Menu.tscn")
