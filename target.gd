extends StaticBody3D

func _ready():
	rotation = Vector3.ZERO

func hit():
	var score = get_tree().get_current_scene().find_child("Score", true, false)
	if score:
		score.add_point()

	var cam = get_viewport().get_camera_3d()
	if cam:
		var screen_pos = cam.unproject_position(global_position)

		var label = Label.new()
		get_tree().root.add_child(label)

		label.text = "+1"
		label.scale = Vector2(2, 2)
		label.position = screen_pos + Vector2(randf_range(-30, 30), randf_range(-30, 30))

		animate_label(label)

	# respawn direct
	global_position = Vector3(
		randf_range(-10, 10),
		randf_range(1, 5),
		10
	)

func animate_label(label):
	var time = 0.0
	
	while time < 1.0:
		await get_tree().process_frame
		label.position.y -= 1.5
		label.modulate.a -= 0.02
		time += 0.016
	
	label.queue_free()
