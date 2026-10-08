extends Node2D

func _draw() -> void:
	# Céu suave de inverno
	draw_rect(Rect2(0, 0, 1920, 1080), Color("#DFF9FB"), true)
	
	# Colinas de neve fofa
	draw_circle(Vector2(400, 1150), 700.0, Color("#C7ECEE"))
	draw_circle(Vector2(1500, 1150), 750.0, Color("#F5F6FA"))
	
	# Chão de neve
	draw_rect(Rect2(0, 750, 1920, 330), Color("#FFFFFF"), true)
	draw_rect(Rect2(0, 750, 1920, 16), Color("#7ED6DF"), true)
	
	# Flocos de neve caindo
	for i in range(16):
		var fx = 120.0 * float(i) + 40.0
		var fy = 150.0 + float(i % 4) * 60.0
		draw_circle(Vector2(fx, fy), 4.0, Color.WHITE)
		
	# 3 Portões de passagem no caminho com emblemas visuais (8, 7 e 6)
	_draw_gate(650, 480, 8)
	_draw_gate(1000, 530, 7)
	_draw_gate(1350, 580, 6)
	
	# Casinha quentinha com chaminé e chá no final (X = 1680)
	draw_rect(Rect2(1650, 560, 200, 190), Color("#E17055"), true, 12.0)
	draw_colored_polygon(PackedVector2Array([Vector2(1630, 560), Vector2(1750, 440), Vector2(1870, 560)]), Color("#D63031"))
	
	# Chaminé com fumacinha
	draw_rect(Rect2(1780, 420, 30, 60), Color("#636E72"), true)
	draw_circle(Vector2(1795, 390), 12.0, Color(1, 1, 1, 0.6))
	draw_circle(Vector2(1815, 360), 16.0, Color(1, 1, 1, 0.4))

func _draw_gate(x: float, y: float, target_num: int) -> void:
	# Pilares de madeira do portão
	draw_rect(Rect2(x, y, 22, 750 - y), Color("#795548"), true, 6.0)
	draw_rect(Rect2(x + 130, y, 22, 750 - y), Color("#795548"), true, 6.0)
	# Barra transversal do topo
	draw_rect(Rect2(x - 10, y, 172, 32), Color("#FFA502"), true, 8.0)
	draw_rect(Rect2(x - 10, y, 172, 32), Color.WHITE, false, 2.0, 8.0)
	
	# Emblema visual central do personagem permitido no portão
	var badge_center = Vector2(x + 76, y + 16)
	_draw_gate_badge(badge_center, target_num)

func _draw_gate_badge(center: Vector2, num: int) -> void:
	# Círculo base com borda dourada
	draw_circle(center, 30.0, Color("#5D4037"))
	draw_circle(center, 27.0, Color("#F1C40F"))
	
	match num:
		8:
			# Emblema do Superócto (8): base magenta e 8 mini-cubos
			draw_circle(center, 24.0, Color("#9B59B6"))
			var sz = 9.0
			var ox = center.x - (sz * 2.0 + 2.0) * 0.5
			var oy = center.y - (sz * 4.0 + 6.0) * 0.5
			for c in range(2):
				for r in range(4):
					draw_rect(Rect2(ox + c * (sz + 2.0), oy + r * (sz + 2.0), sz, sz), Color("#E056FD"), true, 2.0)
			# Mascarinha branca dos olhos do Superócto
			draw_rect(Rect2(center.x - 10, center.y - 12, 20, 6), Color.WHITE, true, 3.0)
		7:
			# Emblema do Sete Arco-Íris: 7 faixas coloridas vibrantes
			draw_circle(center, 24.0, Color("#2C3E50"))
			var colors = [
				Color("#E84118"), Color("#F0932B"), Color("#FFFA65"),
				Color("#44BD32"), Color("#00A8FF"), Color("#3742FA"), Color("#9B59B6")
			]
			var bar_w = 4.8
			var start_x = center.x - (bar_w * 7.0) * 0.5
			for i in range(7):
				draw_rect(Rect2(start_x + i * bar_w, center.y - 18, bar_w - 0.5, 36), colors[i], true, 2.0)
		6:
			# Emblema do Seis (6): base roxa e 6 mini-cubos com pontinhos de dado
			draw_circle(center, 24.0, Color("#6C5CE7"))
			var sz = 11.0
			var ox = center.x - (sz * 2.0 + 3.0) * 0.5
			var oy = center.y - (sz * 3.0 + 4.0) * 0.5
			for c in range(2):
				for r in range(3):
					var cx = ox + c * (sz + 3.0)
					var cy = oy + r * (sz + 2.0)
					draw_rect(Rect2(cx, cy, sz, sz), Color("#A29BFE"), true, 2.0)
					draw_circle(Vector2(cx + sz * 0.5, cy + sz * 0.5), 1.6, Color("#2C3E50"))
