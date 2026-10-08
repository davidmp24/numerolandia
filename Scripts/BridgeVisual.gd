extends Node2D

func _draw() -> void:
	# Ponte de madeira levadiça
	var w = 370.0
	var h = 32.0
	draw_rect(Rect2(0, -h * 0.5, w, h), Color("#8854D0"), true, 8.0)
	# Pregos e tábuas
	for i in range(7):
		var x = 20.0 + (i * 50.0)
		draw_line(Vector2(x, -h * 0.5), Vector2(x, h * 0.5), Color("#5F27CD"), 3.0)
		draw_circle(Vector2(x, 0), 4.0, Color("#FFA502"))
