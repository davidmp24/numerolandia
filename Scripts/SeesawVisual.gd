extends Node2D

## SeesawVisual: Renderização procedural da Gangorra (Fulcro triangular e prancha)

func _draw() -> void:
	# Fulcro triangular central da gangorra
	var fulcrum_pts = PackedVector2Array([
		Vector2(-50, 90),
		Vector2(50, 90),
		Vector2(0, -10)
	])
	draw_colored_polygon(fulcrum_pts, Color("#747D8C"))
	draw_polyline(PackedVector2Array([fulcrum_pts[0], fulcrum_pts[2], fulcrum_pts[1], fulcrum_pts[0]]), Color("#2F3542"), 4.0)
	
	# Eixo circular central
	draw_circle(Vector2(0, -10), 16.0, Color("#FF9F43"))
	draw_circle(Vector2(0, -10), 16.0, Color.WHITE, false, 2.5)
