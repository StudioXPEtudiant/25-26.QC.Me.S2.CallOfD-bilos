extends Control

var color = Color.WHITE
var gap = 10.0
var base_gap = 8.0
var size_line = 10.0
var thickness = 2.0
var center_dot = true

var reload_progress := 0.0
var reloading := false

func _ready():
	size = get_viewport_rect().size

func set_color(new_color):
	color = new_color
	queue_redraw()

func add_recoil(amount):
	gap += amount

func update_gap(target, delta):
	gap = lerp(gap, target, delta * 12.0)
	queue_redraw()

func _draw():
	var center = size / 2

	draw_line(center + Vector2(-gap - size_line, 0), center + Vector2(-gap, 0), color, thickness)
	draw_line(center + Vector2(gap, 0), center + Vector2(gap + size_line, 0), color, thickness)
	draw_line(center + Vector2(0, -gap - size_line), center + Vector2(0, -gap), color, thickness)
	draw_line(center + Vector2(0, gap), center + Vector2(0, gap + size_line), color, thickness)

	if center_dot:
		draw_circle(center, 2.0, color)

	if reloading:
		draw_arc(
			center,
			20,
			-deg_to_rad(90),
			-deg_to_rad(90) + deg_to_rad(360 * reload_progress),
			64,
			Color.WHITE,
			3
		)

func set_gap(new_gap):
	gap = new_gap
	queue_redraw()
