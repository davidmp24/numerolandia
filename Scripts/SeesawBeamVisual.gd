extends Node2D

## SeesawBeamVisual: Desenha a prancha de madeira da gangorra e os assentos

func _draw() -> void:
	# Prancha longa de madeira
	var beam_w = 780.0
	var beam_h = 24.0
	draw_rect(Rect2(-beam_w * 0.5, -beam_h * 0.5, beam_w, beam_h), Color("#E1B12C"), true, 6.0)
	draw_rect(Rect2(-beam_w * 0.5, -beam_h * 0.5, beam_w, beam_h), Color("#C23616"), false, 3.0, 6.0)
	
	# Assentos nas duas pontas
	draw_rect(Rect2(-370, -22, 80, 12), Color("#FF4757"), true, 4.0)
	draw_rect(Rect2(290, -22, 80, 12), Color("#2ED573"), true, 4.0)
