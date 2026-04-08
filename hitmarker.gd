extends Control

func _ready():
	visible = false
	size = get_viewport_rect().size

func show_hitmarker():
	visible = true
	queue_redraw()
	await get_tree().create_timer(0.1).timeout
	visible = false

func _draw():
	var center = size / 2
	draw_line(center + Vector2(-8, -8), center + Vector2(-2, -2), Color.WHITE, 2)
	draw_line(center + Vector2(8, -8), center + Vector2(2, -2), Color.WHITE, 2)
	draw_line(center + Vector2(-8, 8), center + Vector2(-2, 2), Color.WHITE, 2)
	draw_line(center + Vector2(8, 8), center + Vector2(2, 2), Color.WHITE, 2)
