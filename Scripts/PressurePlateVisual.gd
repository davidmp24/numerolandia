extends Node2D

func _draw() -> void:
	# Placa de pressão dourada com símbolo de peso "2"
	draw_rect(Rect2(-55, -12, 110, 24), Color("#FFA502"), true, 8.0)
	draw_rect(Rect2(-48, -8, 96, 16), Color("#FFD32A"), true, 6.0)
	draw_circle(Vector2(0, 0), 10.0, Color("#FF851B"))
