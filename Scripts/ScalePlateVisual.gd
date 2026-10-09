extends Node2D

## ScalePlateVisual: Desenha o prato da balança e as correntes douradas de sustentação

func _draw() -> void:
	# Correntes douradas ligando o topo do prato à haste
	draw_line(Vector2(-70, 0), Vector2(0, -90), Color("#FFA502"), 3.0)
	draw_line(Vector2(70, 0), Vector2(0, -90), Color("#FFA502"), 3.0)
	draw_circle(Vector2(0, -90), 5.0, Color("#E1B12C"))
	
	# Prato arqueado de sustentação dos blocos
	var plate_pts = PackedVector2Array()
	var steps = 16
	for i in range(steps + 1):
		var t = float(i) / float(steps)
		var x = lerpf(-85.0, 85.0, t)
		var y = sin(t * PI) * 16.0
		plate_pts.append(Vector2(x, y))
	plate_pts.append(Vector2(85, 8))
	plate_pts.append(Vector2(-85, 8))
	
	draw_colored_polygon(plate_pts, Color("#E1B12C"))
	draw_polyline(plate_pts, Color("#C23616"), 3.0)
