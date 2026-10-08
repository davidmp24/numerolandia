extends Button

# Botão 100% visual (sem texto) para crianças que ainda não leem.
# Desenha um ícone grande e colorido dentro de um círculo (ou um cubo com bolinhas).

@export var icon_type: String = "home"
@export var bg_color: Color = Color("#FF9F43")
@export var dots: int = 1
@export var dot_color: Color = Color.WHITE
@export var pulse: bool = false

var _t: float = 0.0

func _ready() -> void:
	flat = true
	text = ""
	focus_mode = Control.FOCUS_NONE
	if custom_minimum_size == Vector2.ZERO:
		custom_minimum_size = Vector2(140, 140)
	resized.connect(_update_pivot)
	_update_pivot()
	button_down.connect(_on_down)
	button_up.connect(_on_up)
	set_process(pulse)

func _update_pivot() -> void:
	pivot_offset = size * 0.5

func _process(delta: float) -> void:
	_t += delta
	if pulse and not button_pressed:
		var s = 1.0 + sin(_t * 4.0) * 0.06
		scale = Vector2(s, s)

func _on_down() -> void:
	scale = Vector2(0.9, 0.9)

func _on_up() -> void:
	scale = Vector2.ONE

func _p(c: Vector2, u: float, x: float, y: float) -> Vector2:
	return c + Vector2(x, y) * u

func _poly(c: Vector2, u: float, pts: Array, col: Color) -> void:
	var arr = PackedVector2Array()
	for p in pts:
		arr.append(c + Vector2(p[0], p[1]) * u)
	draw_colored_polygon(arr, col)

func _draw() -> void:
	var c = size * 0.5
	var u = minf(size.x, size.y) / 100.0
	var white = Color.WHITE

	if icon_type == "cube":
		_draw_cube(c, u)
		return

	var r = 46.0 * u
	draw_circle(c + Vector2(0, 5 * u), r, Color(0, 0, 0, 0.25))
	draw_circle(c, r, bg_color)
	draw_arc(c, r - 2 * u, 0, TAU, 48, bg_color.darkened(0.25), 4 * u)
	draw_arc(c, r - 9 * u, PI * 1.05, PI * 1.55, 12, Color(1, 1, 1, 0.35), 4 * u)

	match icon_type:
		"home":
			_poly(c, u, [[-32, -4], [0, -34], [32, -4]], Color("#E74C3C"))
			draw_rect(Rect2(_p(c, u, -23, -4), Vector2(46, 34) * u), white)
			draw_rect(Rect2(_p(c, u, -6, 8), Vector2(12, 22) * u), Color("#795548"))
		"restart":
			draw_arc(c, 24 * u, deg_to_rad(40), deg_to_rad(320), 32, white, 8 * u)
			var a = deg_to_rad(320)
			var e = c + Vector2(cos(a), sin(a)) * 24 * u
			var tan_v = Vector2(-sin(a), cos(a))
			var nor = Vector2(cos(a), sin(a))
			draw_colored_polygon(PackedVector2Array([
				e + tan_v * 16 * u,
				e - tan_v * 2 * u + nor * 13 * u,
				e - tan_v * 2 * u - nor * 13 * u
			]), white)
		"next", "play":
			_poly(c, u, [[-16, -28], [-16, 28], [30, 0]], white)
		"back":
			_poly(c, u, [[16, -28], [16, 28], [-30, 0]], white)
		"speaker":
			draw_rect(Rect2(_p(c, u, -30, -10), Vector2(14, 20) * u), white)
			_poly(c, u, [[-16, -10], [8, -28], [8, 28], [-16, 10]], white)
			draw_arc(_p(c, u, 6, 0), 16 * u, -0.9, 0.9, 12, white, 5 * u)
			draw_arc(_p(c, u, 6, 0), 28 * u, -0.9, 0.9, 12, white, 5 * u)
		"blocks":
			draw_rect(Rect2(_p(c, u, -32, 2), Vector2(28, 28) * u), Color("#FF3838"))
			draw_rect(Rect2(_p(c, u, 4, 2), Vector2(28, 28) * u), Color("#FFDC00"))
			draw_rect(Rect2(_p(c, u, -14, -28), Vector2(28, 28) * u), Color("#2ECC40"))
			draw_circle(_p(c, u, -18, 16), 4 * u, white)
			draw_circle(_p(c, u, 18, 16), 4 * u, white)
			draw_circle(_p(c, u, 0, -14), 4 * u, white)
		"flag":
			draw_line(_p(c, u, -14, -34), _p(c, u, -14, 32), white, 6 * u)
			_poly(c, u, [[-14, -34], [30, -20], [-14, -6]], Color("#FFDC00"))
			draw_circle(_p(c, u, -14, 32), 8 * u, Color("#2ECC40"))
		"clear":
			draw_rect(Rect2(_p(c, u, -20, -6), Vector2(40, 36) * u), white)
			draw_rect(Rect2(_p(c, u, -27, -16), Vector2(54, 9) * u), white)
			draw_rect(Rect2(_p(c, u, -9, -25), Vector2(18, 9) * u), white)
			for i in range(3):
				draw_line(_p(c, u, -10 + i * 10, 2), _p(c, u, -10 + i * 10, 24), bg_color, 4 * u)
		"sneeze":
			draw_circle(c, 30 * u, Color("#C8F7C5"))
			draw_line(_p(c, u, -18, -8), _p(c, u, -8, -4), Color("#2F3542"), 4 * u)
			draw_line(_p(c, u, 18, -8), _p(c, u, 8, -4), Color("#2F3542"), 4 * u)
			draw_circle(_p(c, u, 0, 6), 9 * u, Color("#FF4757"))
			draw_arc(_p(c, u, 0, 20), 8 * u, 0, PI, 8, Color("#2F3542"), 3 * u)
			draw_circle(_p(c, u, 26, 4), 5 * u, Color("#74B9FF"))
			draw_circle(_p(c, u, 32, 14), 4 * u, Color("#74B9FF"))
		"scissors", "cut":
			# Duas lâminas prateadas cruzadas
			_poly(c, u, [[-18, -26], [-10, -28], [8, 8], [0, 10]], Color("#DFE4EA"))
			_poly(c, u, [[18, -26], [10, -28], [-8, 8], [0, 10]], Color("#DFE4EA"))
			# Rebite central
			draw_circle(c + Vector2(0, 8) * u, 4.5 * u, Color("#2F3542"))
			# Argolas vermelhas de segurar a tesoura mágica
			draw_arc(_p(c, u, -15, 22), 10 * u, 0, TAU, 16, Color("#FF4757"), 5 * u)
			draw_arc(_p(c, u, 15, 22), 10 * u, 0, TAU, 16, Color("#FF4757"), 5 * u)
		"rocket":
			_poly(c, u, [[-14, 6], [-30, 28], [-14, 20]], Color("#E74C3C"))
			_poly(c, u, [[14, 6], [30, 28], [14, 20]], Color("#E74C3C"))
			_poly(c, u, [[-9, 20], [0, 40], [9, 20]], Color("#FFA502"))
			_poly(c, u, [[0, -38], [15, -8], [15, 20], [-15, 20], [-15, -8]], white)
			draw_circle(_p(c, u, 0, -8), 7 * u, Color("#0074D9"))
		_:
			draw_circle(c, 14 * u, white)

func _draw_cube(c: Vector2, u: float) -> void:
	var rect = Rect2(c - Vector2(44, 44) * u, Vector2(88, 88) * u)
	var shadow = StyleBoxFlat.new()
	shadow.bg_color = Color(0, 0, 0, 0.25)
	shadow.set_corner_radius_all(int(16 * u))
	draw_style_box(shadow, Rect2(rect.position + Vector2(0, 5 * u), rect.size))
	var sb = StyleBoxFlat.new()
	sb.bg_color = bg_color
	sb.set_corner_radius_all(int(16 * u))
	sb.set_border_width_all(int(4 * u))
	sb.border_color = bg_color.darkened(0.25)
	draw_style_box(sb, rect)

	var n = maxi(dots, 1)
	var cols = n
	if n == 4:
		cols = 2
	elif n > 9:
		cols = 4
	elif n > 3:
		cols = 3
	var rows = int(ceil(float(n) / float(cols)))
	var step = 22.0 * u if rows < 4 and cols < 4 else 19.0 * u
	if n >= 7:
		step = 20.0 * u
	var rad = 7.0 * u if n < 7 else 6.0 * u
	var idx = 0
	for row in range(rows):
		var in_row = mini(cols, n - row * cols)
		for col in range(in_row):
			var px = (float(col) - float(in_row - 1) * 0.5) * step
			var py = (float(row) - float(rows - 1) * 0.5) * step
			draw_circle(c + Vector2(px, py), rad, dot_color)
			idx += 1
