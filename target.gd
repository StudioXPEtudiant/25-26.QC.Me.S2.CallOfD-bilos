extends StaticBody3D

func _ready():
	randomize()

func hit():
	global_position = Vector3(
		randf_range(-10, 10),
		randf_range(1, 5),
		10
	)
