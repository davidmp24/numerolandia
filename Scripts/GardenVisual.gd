extends Node2D

func _draw() -> void:
	# Céu de fim de tarde suave
	draw_rect(Rect2(0, 0, 1920, 1080), Color("#A1E3D8"), true)
	
	# Arco-íris suave ao fundo
	var rainbow_colors = [
		Color(1, 0.3, 0.3, 0.45),
		Color(1, 0.65, 0.2, 0.45),
		Color(1, 0.9, 0.2, 0.45),
		Color(0.3, 0.85, 0.4, 0.45),
		Color(0.2, 0.6, 1.0, 0.45),
		Color(0.4, 0.3, 0.9, 0.45)
	]
	for i in range(rainbow_colors.size()):
		draw_arc(Vector2(960, 950), 650.0 + (i * 20.0), PI, TAU, 64, rainbow_colors[i], 18.0)
		
	# Colinas do Jardim
	draw_circle(Vector2(300, 1050), 550.0, Color("#1DD1A1"))
	draw_circle(Vector2(1620, 1050), 580.0, Color("#10AC84"))
	
	# Chão
	draw_rect(Rect2(0, 750, 1920, 330), Color("#2ED573"), true)
	draw_rect(Rect2(0, 750, 1920, 18), Color("#7BED9F"), true)
	
	# Florzinhas no chão
	var flower_positions = [
		Vector2(200, 830), Vector2(450, 890), Vector2(750, 820),
		Vector2(1150, 850), Vector2(1420, 880), Vector2(1750, 820)
	]
	for fp in flower_positions:
		draw_circle(fp, 10.0, Color.WHITE)
		draw_circle(fp, 5.0, Color("#FFA502"))
