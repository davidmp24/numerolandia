extends Node2D

func _draw() -> void:
	# Céu
	draw_rect(Rect2(0, 0, 1920, 1080), Color("#74B9FF"), true)
	
	# Colinas de fundo
	draw_circle(Vector2(350, 1150), 680.0, Color("#55EFC4"))
	draw_circle(Vector2(1550, 1150), 720.0, Color("#26DE81"))
	
	# Lado esquerdo do jardim
	draw_rect(Rect2(0, 720, 800, 360), Color("#2ED573"), true)
	draw_rect(Rect2(0, 720, 800, 16), Color("#7BED9F"), true)
	
	# Buraco / Abismo entre 800 e 1160
	draw_rect(Rect2(800, 720, 360, 360), Color("#2F3542"), true)
	# Água no fundo do abismo
	draw_rect(Rect2(800, 950, 360, 130), Color("#0984E3"), true)
	
	# Lado direito do jardim (onde fica o botão e o castelinho)
	draw_rect(Rect2(1160, 720, 760, 360), Color("#2ED573"), true)
	draw_rect(Rect2(1160, 720, 760, 16), Color("#7BED9F"), true)
	
	# Casinha / Meta ao final do caminho
	draw_rect(Rect2(1620, 520, 220, 200), Color("#DFE4EA"), true)
	draw_colored_polygon(PackedVector2Array([Vector2(1600, 520), Vector2(1730, 400), Vector2(1860, 520)]), Color("#FF4757"))
	draw_rect(Rect2(1690, 600, 60, 120), Color("#2F3542"), true)
