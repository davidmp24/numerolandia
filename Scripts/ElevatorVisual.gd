extends Node2D

func _draw() -> void:
	# Céu
	draw_rect(Rect2(0, 0, 1920, 1080), Color("#48DBFB"), true)
	
	# Torre do Elevador (Estrutura vertical metálica/futurista no centro)
	draw_rect(Rect2(800, 0, 320, 780), Color("#747D8C"), true)
	draw_rect(Rect2(820, 0, 280, 780), Color("#2F3542"), true)
	
	# Trilhos do elevador
	draw_line(Vector2(840, 0), Vector2(840, 780), Color("#DFE4EA"), 6.0)
	draw_line(Vector2(1080, 0), Vector2(1080, 780), Color("#DFE4EA"), 6.0)
	
	# Chão da torre
	draw_rect(Rect2(0, 750, 1920, 330), Color("#1DD1A1"), true)
	draw_rect(Rect2(0, 750, 1920, 18), Color("#10AC84"), true)
	
	# Placa do elevador com o número 5
	draw_rect(Rect2(890, 80, 140, 60), Color("#0074D9"), true, 12.0)
	draw_rect(Rect2(890, 80, 140, 60), Color.WHITE, false, 4.0, 12.0)
	# Estrela dourada do 5 na placa
	draw_circle(Vector2(960, 110), 18.0, Color("#FFDC00"))
