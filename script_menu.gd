extends CanvasLayer

func _on_play_button_pressed():
	var loading = load("res://Loading.tscn").instantiate()
	get_tree().root.add_child(loading)
	loading.start_loading("res://world.tscn")

func _on_quit_button_pressed():
	get_tree().quit()

func _on_settings_button_pressed():
	var existing = get_tree().root.find_child("Settings", true, false)
	if existing:
		existing.queue_free()

	var settings = load("res://Settings.tscn").instantiate()
	settings.name = "Settings"
	get_tree().root.add_child(settings)

	var player = get_tree().get_first_node_in_group("player")
