extends Node2D

func _draw() -> void:
	# Mesa de madeira clara de brinquedo ou tapete colorido
	draw_rect(Rect2(0, 0, 1920, 1080), Color("#70A1FF"), true)
	
	# Tapete central de atividades
	var carpet_rect = Rect2(120, 140, 1680, 720)
	draw_rect(carpet_rect, Color("#F1F2F6"), true, 40.0)
	draw_rect(carpet_rect, Color("#DFE4EA"), false, 8.0, 40.0)
	
	# Padrão de bolinhas suaves no tapete
	for x in range(200, 1750, 140):
		for y in range(200, 820, 140):
			draw_circle(Vector2(x, y), 5.0, Color(0, 0, 0, 0.05))
