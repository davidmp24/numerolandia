extends Node2D

func _draw() -> void:
	# Maçã vermelha apetitosa
	draw_circle(Vector2(-12, 0), 22.0, Color("#EB4D4B"))
	draw_circle(Vector2(12, 0), 22.0, Color("#EB4D4B"))
	draw_circle(Vector2(0, 10), 20.0, Color("#EB4D4B"))
	
	# Brilho da maçã
	draw_circle(Vector2(-14, -8), 6.0, Color.WHITE)
	
	# Cabinho e folhinha verde
	draw_line(Vector2(0, -22), Vector2(4, -38), Color("#795548"), 4.0)
	draw_circle(Vector2(12, -34), 8.0, Color("#6AB04C"))
