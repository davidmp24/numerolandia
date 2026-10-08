extends Node2D

var is_happy: bool = false
var cloud_color: Color = Color("#747D8C")

func turn_happy() -> void:
	is_happy = true
	cloud_color = Color("#FFEAA7")
	queue_redraw()

func _draw() -> void:
	# Corpo da nuvem
	draw_circle(Vector2(0, 0), 80.0, cloud_color)
	draw_circle(Vector2(-65, 10), 65.0, cloud_color)
	draw_circle(Vector2(65, 10), 65.0, cloud_color)
	draw_circle(Vector2(-40, -45), 55.0, cloud_color)
	draw_circle(Vector2(40, -45), 55.0, cloud_color)
	
	if not is_happy:
		# Olhos caídos e tristes
		draw_circle(Vector2(-28, -5), 8.0, Color.WHITE)
		draw_circle(Vector2(-28, -5), 4.0, Color("#2F3542"))
		draw_circle(Vector2(28, -5), 8.0, Color.WHITE)
		draw_circle(Vector2(28, -5), 4.0, Color("#2F3542"))
		# Boquinha para baixo
		draw_arc(Vector2(0, 32), 16.0, PI, TAU, 10, Color("#2F3542"), 4.0)
	else:
		# Olhos fechados e felizes
		var p1 = [Vector2(-35, -5), Vector2(-28, -12), Vector2(-21, -5)]
		var p2 = [Vector2(21, -5), Vector2(28, -12), Vector2(35, -5)]
		draw_polyline(PackedVector2Array(p1), Color("#2F3542"), 4.0)
		draw_polyline(PackedVector2Array(p2), Color("#2F3542"), 4.0)
		# Bochechinhas rosadas
		draw_circle(Vector2(-42, 8), 10.0, Color("#FF7675"))
		draw_circle(Vector2(42, 8), 10.0, Color("#FF7675"))
		# Grande sorriso
		draw_arc(Vector2(0, 15), 18.0, 0, PI, 10, Color("#2F3542"), 4.0)
