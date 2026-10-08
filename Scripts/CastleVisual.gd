extends Node2D

func _draw() -> void:
	# Céu
	draw_rect(Rect2(0, 0, 1920, 1080), Color("#74B9FF"), true)
	
	# Colinas ao fundo
	draw_circle(Vector2(400, 1150), 650.0, Color("#55EFC4"))
	draw_circle(Vector2(1500, 1150), 750.0, Color("#26DE81"))
	
	# Chão de grama
	draw_rect(Rect2(0, 780, 1920, 300), Color("#2ED573"), true)
	draw_rect(Rect2(0, 780, 1920, 20), Color("#7BED9F"), true) # Borda de grama clara
	
	# Muralha do Castelo (Centro)
	draw_rect(Rect2(660, 360, 600, 440), Color("#747D8C"), true)
	
	# Ameias da muralha
	for i in range(5):
		draw_rect(Rect2(680 + (i * 115), 320, 60, 45), Color("#57606F"), true)
		
	# Torre Esquerda
	draw_rect(Rect2(520, 260, 160, 540), Color("#57606F"), true)
	draw_rect(Rect2(500, 220, 200, 45), Color("#2F3542"), true)
	# Telhado cônico da torre esquerda
	draw_colored_polygon(PackedVector2Array([Vector2(500, 220), Vector2(600, 100), Vector2(700, 220)]), Color("#FF4757"))
	
	# Torre Direita
	draw_rect(Rect2(1240, 260, 160, 540), Color("#57606F"), true)
	draw_rect(Rect2(1220, 220, 200, 45), Color("#2F3542"), true)
	# Telhado cônico da torre direita
	draw_colored_polygon(PackedVector2Array([Vector2(1220, 220), Vector2(1320, 100), Vector2(1420, 220)]), Color("#FF4757"))
	
	# Arco do portão (Vão livre)
	draw_rect(Rect2(800, 480, 320, 310), Color("#2F3542"), true)
	
	# Plataforma da alavanca
	draw_rect(Rect2(1130, 340, 130, 25), Color("#FFA502"), true)
