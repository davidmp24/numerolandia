extends Node2D

func _draw() -> void:
	# Espaço sideral / céu cósmico
	draw_rect(Rect2(0, 0, 1920, 1080), Color("#0C1427"), true)
	
	# Estrelas cintilantes no céu
	for i in range(35):
		var sx = float((i * 57) % 1920)
		var sy = float((i * 31) % 700)
		var r = 2.0 if (i % 3 != 0) else 4.0
		draw_circle(Vector2(sx, sy), r, Color.WHITE)
		
	# Nebulosa cósmica colorida ao fundo
	draw_circle(Vector2(1400, 200), 250.0, Color(0.6, 0.2, 0.9, 0.18))
	draw_circle(Vector2(500, 300), 200.0, Color(0.1, 0.5, 0.9, 0.15))
	
	# Torre de lançamento espacial (lado esquerdo da plataforma)
	draw_rect(Rect2(720, 250, 40, 520), Color("#E74C3C"), true)
	draw_rect(Rect2(720, 250, 40, 520), Color.WHITE, false, 3.0)
	for i in range(10):
		draw_line(Vector2(720, 270 + i * 50), Vector2(760, 270 + i * 50), Color.WHITE, 3.0)
		
	# Plataforma de lançamento central
	draw_rect(Rect2(0, 750, 1920, 330), Color("#2C3E50"), true)
	draw_rect(Rect2(0, 750, 1920, 16), Color("#34495E"), true)
	
	# Base metálica do foguete (Pad de concreto circular)
	draw_rect(Rect2(820, 720, 280, 40), Color("#7F8C8D"), true, 12.0)
	draw_rect(Rect2(850, 710, 220, 20), Color("#E67E22"), true, 8.0)
	
	# Holofotes de iluminação apontando para o centro
	var light1 = PackedVector2Array([Vector2(650, 750), Vector2(940, 500), Vector2(980, 500)])
	var light2 = PackedVector2Array([Vector2(1270, 750), Vector2(980, 500), Vector2(940, 500)])
	draw_colored_polygon(light1, Color(1, 1, 0.7, 0.12))
	draw_colored_polygon(light2, Color(1, 1, 0.7, 0.12))
