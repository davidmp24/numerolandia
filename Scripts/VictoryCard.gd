extends Control

# Cartão de vitória: painel colorido com 3 estrelas grandes (sem texto).

func _draw() -> void:
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color("#FFF3C4")
	sb.set_corner_radius_all(48)
	sb.set_border_width_all(10)
	sb.border_color = Color("#FFB142")
	draw_style_box(sb, Rect2(Vector2.ZERO, size))
	for i in range(3):
		var middle = (i == 1)
		var c = Vector2(size.x * 0.5 + float(i - 1) * 190.0, 120.0 if middle else 170.0)
		_star(c, 85.0 if middle else 68.0)

func _star(center: Vector2, radius: float) -> void:
	var pts = PackedVector2Array()
	for i in range(10):
		var a = (float(i) / 10.0) * TAU - PI * 0.5
		var r = radius if (i % 2 == 0) else radius * 0.45
		pts.append(center + Vector2(cos(a), sin(a)) * r)
	draw_colored_polygon(pts, Color("#FFD32A"))
	pts.append(pts[0])
	draw_polyline(pts, Color("#E67E22"), 6.0)
