extends Node2D


func _draw() -> void:
	# Céu noturno estrelado
	draw_rect(Rect2(0, 0, 1920, 1080), Color("#2C3E50"), true)
	
	# Montanha rochosa à direita
	var mountain = PackedVector2Array([
		Vector2(850, 780),
		Vector2(1150, 240),
		Vector2(1920, 240),
		Vector2(1920, 780)
	])
	draw_colored_polygon(mountain, Color("#34495E"))
	
	# Chão da caverna
	draw_rect(Rect2(0, 750, 1920, 330), Color("#7F8C8D"), true)
	draw_rect(Rect2(0, 750, 1920, 18), Color("#BDC3C7"), true)
	
	# Túnel da Caverna (Entrada em X = 1100 a 1600)
	draw_rect(Rect2(1100, 520, 500, 230), Color("#1A252F"), true, 24.0)
	
	# Moldura de entrada do túnel (arco de pedra e madeira)
	draw_rect(Rect2(1070, 480, 50, 270), Color("#4A5568"), true, 10.0)
	draw_rect(Rect2(1060, 470, 70, 30), Color("#E1B12C"), true, 8.0)
	
	# Emblema visual do Quatro (Silhueta 2x2 verde com pontos de dado, 100% sem texto!)
	_draw_four_badge(Vector2(1095, 420))

# Desenha o emblema visual do personagem Quatro (2 colunas x 2 linhas, quadrado verde)
func _draw_four_badge(center: Vector2) -> void:
	# Placa de madeira arredondada com borda dourada
	draw_rect(Rect2(center.x - 52, center.y - 52, 104, 104), Color("#5D4037"), true, 14.0)
	draw_rect(Rect2(center.x - 46, center.y - 46, 92, 92), Color("#F1C40F"), true, 10.0)
	draw_rect(Rect2(center.x - 42, center.y - 42, 84, 84), Color("#2ECC40"), true, 8.0)
	
	# Grade 2x2 de mini-cubos do Quatro (Quadrado perfeito verde)
	var mini_cube_size = 32.0
	var spacing = 4.0
	var start_x = center.x - (mini_cube_size * 2.0 + spacing) * 0.5
	var start_y = center.y - (mini_cube_size * 2.0 + spacing) * 0.5
	
	for col in range(2):
		for row in range(2):
			var bx = start_x + float(col) * (mini_cube_size + spacing)
			var by = start_y + float(row) * (mini_cube_size + spacing)
			# Mini cubo verde claro
			draw_rect(Rect2(bx, by, mini_cube_size, mini_cube_size), Color("#2ECC71"), true, 4.0)
			draw_rect(Rect2(bx, by, mini_cube_size, mini_cube_size), Color.WHITE, false, 2.0, 4.0)
			# Olhinho / Ponto central do 4
			draw_circle(Vector2(bx + mini_cube_size * 0.5, by + mini_cube_size * 0.5), 3.5, Color("#2C3E50"))
			
	# Barra de altura máxima permitida (linha guia iluminada)
	draw_line(Vector2(1070, 560), Vector2(1600, 560), Color(0.2, 0.85, 0.4, 0.6), 4.0)
