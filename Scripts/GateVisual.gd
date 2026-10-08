extends Node2D

func _draw() -> void:
	# Portão de madeira com barras de ferro
	var w = 310.0
	var h = 300.0
	draw_rect(Rect2(0, 0, w, h), Color("#8854D0"), true)
	
	# Barras verticais
	for i in range(6):
		var x = 20.0 + (i * 54.0)
		draw_line(Vector2(x, 0), Vector2(x, h), Color("#2F3542"), 8.0)
		
	# Barras horizontais
	draw_line(Vector2(0, 60), Vector2(w, 60), Color("#2F3542"), 10.0)
	draw_line(Vector2(0, 180), Vector2(w, 180), Color("#2F3542"), 10.0)
	draw_line(Vector2(0, 270), Vector2(w, 270), Color("#2F3542"), 10.0)
