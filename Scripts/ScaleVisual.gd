extends Node2D

## ScaleVisual: Renderização procedural amigável e colorida da Balança Mágica
## Desenha o suporte triangular central, o fulcro, o braço e os pratos com correntes

@onready var scale_node: MagicScale = get_parent() as MagicScale

func _draw() -> void:
	# Suporte triangular central (Base fixada no chão)
	var base_pts = PackedVector2Array([
		Vector2(-45, 120),
		Vector2(45, 120),
		Vector2(12, -15),
		Vector2(-12, -15)
	])
	draw_colored_polygon(base_pts, Color("#747D8C"))
	draw_polyline(PackedVector2Array([base_pts[0], base_pts[3], base_pts[2], base_pts[1], base_pts[0]]), Color("#2F3542"), 3.5)
	
	# Eixo circular central (Fulcro com joia mágica azul)
	draw_circle(Vector2(0, 0), 22.0, Color("#57606F"))
	draw_circle(Vector2(0, 0), 16.0, Color("#3742FA"))
	draw_circle(Vector2(0, 0), 16.0, Color.WHITE, false, 2.5)
	draw_circle(Vector2(4, -4), 4.0, Color.WHITE)

func _process(_delta: float) -> void:
	queue_redraw()
