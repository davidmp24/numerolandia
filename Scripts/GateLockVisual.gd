extends Node2D

## GateLockVisual: Cadeado com joia brilhante que se destranca na igualdade

func _draw() -> void:
	# Arco de ferro do cadeado
	draw_arc(Vector2(0, -22), 20.0, PI, TAU, 16, Color("#FFA502"), 6.0)
	
	# Corpo do cadeado
	draw_rect(Rect2(-28, -12, 56, 44), Color("#FF9F43"), true, 8.0)
	draw_rect(Rect2(-28, -12, 56, 44), Color.WHITE, false, 2.5, 8.0)
	
	# Fechadura mágica em formato de estrela ou número 4
	draw_circle(Vector2(0, 10), 8.0, Color("#2F3542"))
	draw_circle(Vector2(0, 10), 5.0, Color("#3742FA"))
