extends Node2D

## GateDoorVisual: Desenha a folha de grade do portão mágico

@export var is_right_door: bool = false

func _draw() -> void:
	var w = 150.0
	var h = 300.0
	var x_offset = 0.0 if not is_right_door else -w
	
	draw_rect(Rect2(x_offset, -150, w, h), Color("#2F3542"), true, 8.0)
	draw_rect(Rect2(x_offset, -150, w, h), Color("#70A1FF"), false, 4.0, 8.0)
	
	# Barras verticais douradas
	for i in range(4):
		var x = x_offset + 18.0 + (i * 36.0)
		draw_line(Vector2(x, -140), Vector2(x, 140), Color("#FFA502"), 4.5)
