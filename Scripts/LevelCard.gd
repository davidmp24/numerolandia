extends Button

const ProgressScript = preload("res://Scripts/Progress.gd")

# Cartão de fase só com figuras: a criança reconhece a fase pelo desenho.
# As bolinhas embaixo indicam a ordem (1 a 7); a estrela mostra fase concluída.

@export var level_index: int = 1
@export var card_color: Color = Color("#54A0FF")
@export var scene_path: String = ""

func _ready() -> void:
	flat = true
	text = ""
	focus_mode = Control.FOCUS_NONE
	custom_minimum_size = Vector2(330, 330)
	resized.connect(func(): pivot_offset = size * 0.5)
	pivot_offset = size * 0.5
	button_down.connect(func(): scale = Vector2(0.94, 0.94))
	button_up.connect(func(): scale = Vector2.ONE)

func _poly(c: Vector2, u: float, pts: Array, col: Color) -> void:
	var arr = PackedVector2Array()
	for p in pts:
		arr.append(c + Vector2(p[0], p[1]) * u)
	draw_colored_polygon(arr, col)

func _draw() -> void:
	var rect = Rect2(Vector2.ZERO, size)
	var sb = StyleBoxFlat.new()
	sb.bg_color = card_color
	sb.set_corner_radius_all(36)
	sb.set_border_width_all(8)
	sb.border_color = card_color.darkened(0.3)
	sb.shadow_color = Color(0, 0, 0, 0.3)
	sb.shadow_size = 8
	sb.shadow_offset = Vector2(0, 6)
	draw_style_box(sb, rect)

	# Janela da ilustração
	var win = StyleBoxFlat.new()
	win.bg_color = Color("#DFF6FF")
	win.set_corner_radius_all(24)
	draw_style_box(win, Rect2(Vector2(22, 22), Vector2(size.x - 44, size.y - 110)))

	var c = Vector2(size.x * 0.5, 22 + (size.y - 110) * 0.5)
	var u = (size.y - 110) / 120.0
	_draw_scene(c, u)

	# Bolinhas de ordem (ajustadas dinamicamente para até 9 fases)
	var n = level_index
	var spacing = 24.0 if n > 7 else 30.0
	var dot_radius = 8.5 if n > 7 else 11.0
	var start_x = size.x * 0.5 - float(n - 1) * spacing * 0.5
	for i in range(n):
		var p = Vector2(start_x + float(i) * spacing, size.y - 42)
		draw_circle(p, dot_radius, Color.WHITE)
		draw_circle(p, dot_radius, card_color.darkened(0.3), false, 2.0)

	# Estrela de fase concluída
	if scene_path != "" and ProgressScript.is_done(scene_path):
		_draw_star(Vector2(size.x - 44, 44), 30.0, Color("#FFD32A"))

func _draw_star(center: Vector2, radius: float, col: Color) -> void:
	var pts = PackedVector2Array()
	for i in range(10):
		var a = (float(i) / 10.0) * TAU - PI * 0.5
		var r = radius if (i % 2 == 0) else radius * 0.45
		pts.append(center + Vector2(cos(a), sin(a)) * r)
	draw_colored_polygon(pts, col)
	draw_polyline(PackedVector2Array(pts + PackedVector2Array([pts[0]])), Color("#E67E22"), 3.0)

func _cube(c: Vector2, u: float, x: float, y: float, s: float, col: Color, n: int) -> void:
	var r = Rect2(c + Vector2(x, y) * u, Vector2(s, s) * u)
	draw_rect(r, col)
	draw_rect(r, col.darkened(0.3), false, 3.0)
	var mid = r.position + r.size * 0.5
	if n == 1:
		draw_circle(mid, 4 * u, Color.WHITE)
	elif n == 2:
		draw_circle(mid + Vector2(-5, 0) * u, 3.5 * u, Color.WHITE)
		draw_circle(mid + Vector2(5, 0) * u, 3.5 * u, Color.WHITE)

func _draw_scene(c: Vector2, u: float) -> void:
	match level_index:
		1:
			# Ponte sobre o buraco, cubo 1 e cubo 1
			draw_rect(Rect2(c + Vector2(-60, 20) * u, Vector2(38, 40) * u), Color("#2ED573"))
			draw_rect(Rect2(c + Vector2(22, 20) * u, Vector2(38, 40) * u), Color("#2ED573"))
			draw_rect(Rect2(c + Vector2(-22, 44) * u, Vector2(44, 16) * u), Color("#0984E3"))
			draw_rect(Rect2(c + Vector2(-24, 14) * u, Vector2(48, 8) * u), Color("#8854D0"))
			_cube(c, u, -52, -14, 28, Color("#FF3838"), 1)
			_cube(c, u, -8, -40, 28, Color("#FF3838"), 1)
			_cube(c, u, 28, -14, 28, Color("#FF851B"), 2)
		2:
			# Macieira
			draw_rect(Rect2(c + Vector2(-8, 0) * u, Vector2(16, 60) * u), Color("#795548"))
			draw_circle(c + Vector2(0, -18) * u, 38 * u, Color("#44BD32"))
			draw_circle(c + Vector2(-16, -4) * u, 14 * u, Color("#EB4D4B"))
			draw_circle(c + Vector2(18, -28) * u, 14 * u, Color("#EB4D4B"))
			_cube(c, u, -58, 30, 26, Color("#FF851B"), 2)
		3:
			# Elevador com seta para cima
			draw_rect(Rect2(c + Vector2(-34, -52) * u, Vector2(68, 108) * u), Color("#747D8C"))
			draw_rect(Rect2(c + Vector2(-26, -20) * u, Vector2(52, 70) * u), Color("#70A1FF"))
			_poly(c, u, [[-16, -30], [16, -30], [0, -50]], Color("#FFDC00"))
			_cube(c, u, -12, 18, 24, Color("#0074D9"), 0)
		4:
			# Nuvem e arco-íris
			var cols = [Color("#FF3838"), Color("#FF851B"), Color("#FFDC00"), Color("#2ECC40"), Color("#0074D9"), Color("#8854D0")]
			for i in range(cols.size()):
				draw_arc(c + Vector2(0, 40) * u, (54 - i * 5) * u, PI, TAU, 24, cols[i], 5 * u)
			draw_circle(c + Vector2(-20, 34) * u, 18 * u, Color.WHITE)
			draw_circle(c + Vector2(0, 28) * u, 22 * u, Color.WHITE)
			draw_circle(c + Vector2(20, 34) * u, 18 * u, Color.WHITE)
		5:
			# Caverna e corte
			_poly(c, u, [[-62, 60], [-10, -40], [30, -40], [62, 60]], Color("#7F8C8D"))
			draw_circle(c + Vector2(10, 40) * u, 22 * u, Color("#1A252F"))
			draw_rect(Rect2(c + Vector2(-12, 40) * u, Vector2(44, 20) * u), Color("#1A252F"))
			_cube(c, u, -56, 10, 30, Color("#E84393"), 0)
			draw_line(c + Vector2(-62, 0) * u, c + Vector2(-20, 52) * u, Color("#2F3542"), 4)
		6:
			# 9 resfriado: rostinho com nariz vermelho e gotinhas
			draw_rect(Rect2(c + Vector2(-34, -34) * u, Vector2(68, 68) * u), Color("#A4B0BE"))
			draw_circle(c + Vector2(-14, -8) * u, 7 * u, Color.WHITE)
			draw_circle(c + Vector2(14, -8) * u, 7 * u, Color.WHITE)
			draw_circle(c + Vector2(0, 10) * u, 8 * u, Color("#FF4757"))
			draw_circle(c + Vector2(26, 28) * u, 6 * u, Color("#74B9FF"))
			draw_circle(c + Vector2(40, 40) * u, 5 * u, Color("#74B9FF"))
		7:
			# Foguete
			_poly(c, u, [[-18, 18], [-38, 52], [-18, 40]], Color("#E74C3C"))
			_poly(c, u, [[18, 18], [38, 52], [18, 40]], Color("#E74C3C"))
			_poly(c, u, [[-12, 42], [0, 64], [12, 42]], Color("#FFA502"))
			_poly(c, u, [[0, -58], [22, -14], [22, 42], [-22, 42], [-22, -14]], Color.WHITE)
			draw_circle(c + Vector2(0, -12) * u, 10 * u, Color("#0074D9"))
		8:
			# Bônus: Castelo e Alavanca Dourada
			draw_rect(Rect2(c + Vector2(-45, -20) * u, Vector2(90, 70) * u), Color("#747D8C"))
			draw_rect(Rect2(c + Vector2(-20, 10) * u, Vector2(40, 40) * u), Color("#2F3542"))
			_poly(c, u, [[-45, -20], [-25, -45], [-5, -20]], Color("#FF4757"))
			_poly(c, u, [[5, -20], [25, -45], [45, -20]], Color("#FF4757"))
			draw_circle(c + Vector2(25, -5) * u, 7 * u, Color("#FFD32A"))
		9:
			# Bônus: Criaturinha Fofa e Bloco Arco-Íris 7
			draw_circle(c + Vector2(-15, 5) * u, 24 * u, Color("#FF9FF3"))
			draw_circle(c + Vector2(-22, -2) * u, 4 * u, Color("#2F3542"))
			draw_circle(c + Vector2(-8, -2) * u, 4 * u, Color("#2F3542"))
			draw_arc(c + Vector2(-15, 6) * u, 8 * u, 0, PI, 8, Color("#2F3542"), 2.5 * u)
			_cube(c, u, 12, -15, 26, Color("#8854D0"), 0)
			draw_circle(c + Vector2(25, -2) * u, 4 * u, Color("#FFD32A"))
