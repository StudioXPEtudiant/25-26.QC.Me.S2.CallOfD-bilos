extends CanvasLayer

var slider

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

	await get_tree().process_frame

	slider = find_child("SensitivitySlider", true, false)

	if slider:
		slider.set_value_no_signal(Global.sensitivity)

		if not slider.value_changed.is_connected(_on_sensitivity_slider_value_changed):
			slider.value_changed.connect(_on_sensitivity_slider_value_changed)

func _on_sensitivity_slider_value_changed(value):
	Global.sensitivity = value

	var player = get_tree().get_first_node_in_group("player")

	if player:
		player.mouse_sensitivity = value
		player.base_sensitivity = value

func _on_back_button_pressed():
	queue_free()
