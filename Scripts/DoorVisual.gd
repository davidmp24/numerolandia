extends Node2D

func _draw() -> void:
	# Cabine do elevador
	var w = 240.0
	var h = 320.0
	draw_rect(Rect2(-w * 0.5, -h * 0.5, w, h), Color("#70A1FF"), false, 10.0, 16.0)
	draw_rect(Rect2(-w * 0.5 + 5, -h * 0.5 + 5, w - 10, h - 10), Color(0.1, 0.4, 0.9, 0.25), true, 12.0)
	
	# Luva e estrela do 5 na parte superior da cabine
	draw_circle(Vector2(0, -h * 0.5 + 35), 20.0, Color("#0074D9"))
	draw_circle(Vector2(0, -h * 0.5 + 35), 14.0, Color("#FFDC00"))
