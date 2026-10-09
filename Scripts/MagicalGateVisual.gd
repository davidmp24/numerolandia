extends Node2D

## MagicalGateVisual: Desenha os pilares de pedra e arcos do Portão Mágico

func _draw() -> void:
	# Pilares do portão
	draw_rect(Rect2(-240, -180, 70, 360), Color("#57606F"), true, 12.0)
	draw_rect(Rect2(170, -180, 70, 360), Color("#57606F"), true, 12.0)
	
	# Arco superior
	draw_rect(Rect2(-240, -210, 480, 60), Color("#747D8C"), true, 12.0)
	draw_circle(Vector2(0, -180), 28.0, Color("#3742FA"))
	draw_circle(Vector2(0, -180), 28.0, Color.WHITE, false, 3.0)
