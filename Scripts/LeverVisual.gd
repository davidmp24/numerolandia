extends Node2D

func _draw() -> void:
	# Base da alavanca
	draw_rect(Rect2(-20, -10, 40, 20), Color("#747D8C"), true)
	# Haste
	draw_line(Vector2(0, 0), Vector2(0, -60), Color("#DFE4EA"), 8.0)
	# Esfera dourada no topo da alavanca
	draw_circle(Vector2(0, -60), 16.0, Color("#FFD32A"))
	draw_circle(Vector2(0, -60), 16.0, Color("#FFA801"), false, 3.0)
