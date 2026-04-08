extends Control

var color = Color.WHITE

func _ready():
	visible = false
	size = get_viewport_rect().size
	queue_redraw()

func set_color(new_color):
	if color == new_color:
		return
	color = new_color
	queue_redraw()

func _draw():
	var center = size / 2
	
	draw_line(center + Vector2(-10, 0), center + Vector2(10, 0), color, 2)
	draw_line(center + Vector2(0, -10), center + Vector2(0, 10), color, 2)
