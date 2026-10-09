extends Node2D

## GrowthTunnelVisual: Renderização do Túnel/Máquina de Crescimento com Medidor de Altura

func _draw() -> void:
	# Estrutura do túnel
	var tw = 550.0
	var th = 380.0
	var pos = Vector2(0, -th)
	
	# Tubo do túnel em azul tecnológico suave
	draw_rect(Rect2(pos.x, pos.y, tw, th), Color("#2F3542"), true, 16.0)
	draw_rect(Rect2(pos.x, pos.y, tw, th), Color("#70A1FF"), false, 5.0, 16.0)
	
	# Entrada do túnel com medidor de tamanho 6
	draw_rect(Rect2(pos.x - 20, pos.y - 30, 80, 50), Color("#FF9F43"), true, 8.0)
	draw_rect(Rect2(pos.x - 20, pos.y - 30, 80, 50), Color.WHITE, false, 2.5, 8.0)
	
	var font = _get_default_font()
	var label_txt = "ALTURA 6"
	var sz = font.get_string_size(label_txt, HORIZONTAL_ALIGNMENT_CENTER, -1, 16)
	draw_string(font, Vector2(pos.x + 20 - sz.x * 0.5, pos.y - 6), label_txt, HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color("#2F3542"))
	
	# Linha régua medidora de altura na entrada
	for r in range(7):
		var y = pos.y + th - (float(r) * 46.0)
		draw_line(Vector2(pos.x + 10, y), Vector2(pos.x + 35, y), Color("#FFFA65"), 3.0)
		var num_str = str(r)
		draw_string(font, Vector2(pos.x + 40, y + 4), num_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)

func _get_default_font() -> Font:
	if ThemeDB and "fallback_font" in ThemeDB and ThemeDB.fallback_font:
		return ThemeDB.fallback_font
	return ThemeDB.get_fallback_font()
