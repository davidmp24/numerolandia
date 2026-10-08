extends Node2D

var time: float = 0.0

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	# Gradiente de céu azul turquesa
	draw_rect(Rect2(0, 0, 1920, 1080), Color("#48DBFB"), true)
	
	# Colinas suaves
	draw_circle(Vector2(300, 1200), 700.0, Color("#1DD1A1"))
	draw_circle(Vector2(1620, 1200), 750.0, Color("#10AC84"))
	draw_circle(Vector2(960, 1250), 720.0, Color("#2ED573"))
	
	# Nuvens flutuando
	_draw_cloud(Vector2(250 + sin(time * 0.5) * 40, 200))
	_draw_cloud(Vector2(1650 + cos(time * 0.4) * 35, 260))
	_draw_cloud(Vector2(980 + sin(time * 0.3) * 50, 120))
	
	# Dois bloquinhos mascotes decorativos no fundo
	_draw_mini_mascot_1(Vector2(280, 780 + sin(time * 4.0) * 10))
	_draw_mini_mascot_7(Vector2(1640, 780 + cos(time * 4.0) * 10))

func _draw_cloud(pos: Vector2) -> void:
	draw_circle(pos, 45.0, Color(1, 1, 1, 0.85))
	draw_circle(pos + Vector2(40, -10), 38.0, Color(1, 1, 1, 0.85))
	draw_circle(pos + Vector2(-35, -5), 32.0, Color(1, 1, 1, 0.85))

func _draw_mini_mascot_1(pos: Vector2) -> void:
	var r = Rect2(pos - Vector2(45, 45), Vector2(90, 90))
	draw_rect(r, Color("#FF4757"), true, 18.0)
	draw_circle(pos - Vector2(0, 8), 16.0, Color.WHITE)
	draw_circle(pos - Vector2(0, 8), 8.0, Color("#2F3542"))
	draw_circle(pos - Vector2(-2, 10), 3.0, Color.WHITE)
	draw_arc(pos + Vector2(0, 20), 12.0, 0, PI, 10, Color("#2F3542"), 3.5)

func _draw_mini_mascot_7(pos: Vector2) -> void:
	var r = Rect2(pos - Vector2(45, 45), Vector2(90, 90))
	draw_rect(r, Color("#9C88FF"), true, 18.0)
	draw_circle(pos + Vector2(-16, -10), 12.0, Color.WHITE)
	draw_circle(pos + Vector2(-16, -10), 6.0, Color("#2F3542"))
	draw_circle(pos + Vector2(16, -10), 12.0, Color.WHITE)
	draw_circle(pos + Vector2(16, -10), 6.0, Color("#2F3542"))
	draw_arc(pos + Vector2(0, 18), 14.0, 0, PI, 10, Color("#2F3542"), 3.5)
