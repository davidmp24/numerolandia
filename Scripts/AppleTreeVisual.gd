extends Node2D

func _draw() -> void:
	# Céu ensolarado
	draw_rect(Rect2(0, 0, 1920, 1080), Color("#686DE0"), true)
	
	# Sol brilhante
	draw_circle(Vector2(200, 200), 75.0, Color("#F9CA24"))
	draw_circle(Vector2(200, 200), 95.0, Color(1, 0.9, 0.2, 0.3))
	
	# Colinas
	draw_circle(Vector2(400, 1150), 700.0, Color("#6AB04C"))
	draw_circle(Vector2(1600, 1150), 750.0, Color("#4834D4"))
	
	# Chão
	draw_rect(Rect2(0, 750, 1920, 330), Color("#BADC58"), true)
	draw_rect(Rect2(0, 750, 1920, 16), Color("#6AB04C"), true)
	
	# Tronco da Macieira (lado direito)
	draw_rect(Rect2(1200, 360, 90, 400), Color("#795548"), true, 16.0)
	
	# Galho que se estende para a esquerda
	draw_rect(Rect2(950, 430, 280, 42), Color("#795548"), true, 12.0)
	
	# Copa frondosa da árvore (nuvens verdes de folhas)
	draw_circle(Vector2(1240, 330), 180.0, Color("#44BD32"))
	draw_circle(Vector2(1080, 370), 140.0, Color("#4CD137"))
	draw_circle(Vector2(1380, 380), 130.0, Color("#4CD137"))
	draw_circle(Vector2(1240, 220), 140.0, Color("#44BD32"))
