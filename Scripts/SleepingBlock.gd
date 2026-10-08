extends Area2D
class_name SleepingBlock

## SleepingBlock: Bloco Dorminhoco para Ensino de Subitização e Correspondência Biunívoca
## Projeto: Numerolândia Kids (Fase 1: O Jardim das Quantidades - Crianças de 4 anos)

# Sinais nativos do Godot 4 para comunicação com o LevelManager
signal block_awakened(block: SleepingBlock, value: int)
signal touch_progressed(current_touches: int, max_touches: int)

# Configurações Pedagógicas e Estado
@export var valor_maximo: int = 1 ## Quantidade de toques necessários para acordar (1, 2 ou 3)
var toques_atuais: int = 0         ## Contador de toques registrados
var is_awake: bool = false         ## Indica se o bloco já despertou totalmente
var is_animating: bool = false     ## Trava de cooldown anti-spam para evitar múltiplos toques acidentais

# Dimensões e Proporções
const CUBE_SIZE: float = 48.0
const HITBOX_EXPANSION_FACTOR: float = 1.45 ## Hitbox 45% maior para facilitar o toque de crianças pequenas

# Controle de Animações e Expressões
var original_position_y: float = 0.0
var idle_time: float = 0.0
var zzz_time: float = 0.0
var is_blinking: bool = false
var blink_timer: float = 0.0
var next_blink_interval: float = 3.0

# Balão de fala individual
var speech_text: String = ""
var speech_timer: float = 0.0

# Nós Internos
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("sleeping_blocks")
	original_position_y = position.y
	idle_time = randf() * TAU
	zzz_time = randf() * TAU
	next_blink_interval = randf_range(2.5, 4.5)
	
	# Conexão de eventos de entrada no Area2D
	input_event.connect(_on_input_event)
	
	# Configura a Hitbox expandida para acessibilidade motora infantil (+45% de margem)
	_setup_expanded_hitbox()
	queue_redraw()

func _process(delta: float) -> void:
	idle_time += delta
	zzz_time += delta
	
	# Piscar de olhos quando acordado
	if is_awake:
		blink_timer += delta
		if not is_blinking and blink_timer >= next_blink_interval:
			is_blinking = true
			queue_redraw()
			get_tree().create_timer(0.12).timeout.connect(func():
				if is_instance_valid(self):
					is_blinking = false
					blink_timer = 0.0
					next_blink_interval = randf_range(2.5, 5.0)
					queue_redraw()
			)
			
	# Temporizador do balão de fala
	if speech_timer > 0.0:
		speech_timer -= delta
		if speech_timer <= 0.0:
			speech_text = ""
			queue_redraw()
			
	# Atualiza o desenho para animar Zzz (se dormindo) ou respiração (se acordado)
	queue_redraw()

## Configura o CollisionShape2D garantindo no mínimo 30-45% de área extra para facilitar o toque
func _setup_expanded_hitbox() -> void:
	if not collision_shape:
		collision_shape = CollisionShape2D.new()
		add_child(collision_shape)
		
	var shape = RectangleShape2D.new()
	var base_w = CUBE_SIZE
	var base_h = float(valor_maximo) * CUBE_SIZE
	
	# Aplica o fator de expansão de hitbox (+45%)
	shape.size = Vector2(base_w * HITBOX_EXPANSION_FACTOR + 20.0, base_h * HITBOX_EXPANSION_FACTOR + 30.0)
	collision_shape.shape = shape
	collision_shape.position = Vector2(0, 0)

## Trata eventos de clique de mouse ou toque touch na tela
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	var is_pressed_touch = (event is InputEventScreenTouch and event.pressed)
	var is_pressed_mouse = (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed)
	
	if is_pressed_touch or is_pressed_mouse:
		handle_tap()

## Lógica principal de toque com prevenção de spam e correspondência biunívoca
func handle_tap() -> void:
	# Trava de Cooldown / Anti-Spam: Se já estiver acordado ou executando animação/áudio, ignora novos toques
	if is_awake or is_animating:
		return
		
	is_animating = true
	toques_atuais += 1
	emit_signal("touch_progressed", toques_atuais, valor_maximo)
	
	if toques_atuais < valor_maximo:
		# Toque Intermediário: Iluminação progressiva, salto leve e contagem parcial
		_handle_intermediate_touch()
	else:
		# Despertar Completo: Pulo elástico, áudio final de vitória e emissão de sinal
		_handle_full_awakening()

## Feedback de toque intermediário (ex: 1º toque no Bloco 2 ou 1º/2º toque no Bloco 3)
func _handle_intermediate_touch() -> void:
	var count_text = ""
	match toques_atuais:
		1:
			count_text = "Um..."
		2:
			count_text = "Dois..."
		_:
			count_text = "%d..." % toques_atuais
			
	show_speech(count_text, 1.0)
	_play_voice_feedback(count_text, toques_atuais)
	
	# Animação suave de sobressalto / espreguiçada
	var tw = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "position:y", original_position_y - 20.0, 0.15)
	tw.parallel().tween_property(self, "scale", Vector2(1.15, 0.9), 0.15)
	
	tw.tween_property(self, "position:y", original_position_y, 0.2)
	tw.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
	
	await tw.finished
	# Cooldown de 0.35s para garantir que a criança compreenda o número antes do próximo toque
	await get_tree().create_timer(0.35).timeout
	if not is_awake:
		is_animating = false

## Feedback de despertar completo (atingiu o valor_maximo de toques)
func _handle_full_awakening() -> void:
	is_awake = true
	
	var final_phrase = ""
	match valor_maximo:
		1:
			final_phrase = "Um!"
		2:
			final_phrase = "Dois... Sou o Dois!"
		3:
			final_phrase = "Três... Sou o Três!"
		_:
			final_phrase = "Sou o %d!" % valor_maximo
			
	show_speech(final_phrase, 2.2)
	_play_voice_feedback(final_phrase, valor_maximo)
	
	# Pulo Elástico usando Tween do Godot 4 (alterando position:y e scale)
	var tw = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	# Fase 1: Agachamento preparatório
	var tw_squash = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw_squash.tween_property(self, "scale", Vector2(1.25, 0.75), 0.12)
	tw_squash.parallel().tween_property(self, "position:y", original_position_y + 8.0, 0.12)
	await tw_squash.finished
	
	# Fase 2: Pulo elástico alto e expansão
	tw.tween_property(self, "position:y", original_position_y - 75.0, 0.25)
	tw.parallel().tween_property(self, "scale", Vector2(0.9, 1.25), 0.2)
	
	# Fase 3: Aterrissagem com amortecimento elástico
	tw.tween_property(self, "position:y", original_position_y, 0.35)
	tw.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.35)
	
	await tw.finished
	is_animating = false
	
	# Emite sinal para o LevelManager informando que o bloco despertou
	emit_signal("block_awakened", self, valor_maximo)

## Emite o áudio pedagógico por meio do AudioManager ou fala sintetizada
func _play_voice_feedback(text: String, num_pitch: int) -> void:
	if AudioManager:
		AudioManager.speak(text)
		AudioManager.play_synth_note(num_pitch)

## Exibe balão de fala animado acima do personagem
func show_speech(text: String, duration: float = 2.0) -> void:
	speech_text = text
	speech_timer = duration
	queue_redraw()

# ==============================================================================
# RENDERIZAÇÃO PROCEDURAL GRÁFICA (GODOT 4 _draw)
# ==============================================================================
func _draw() -> void:
	var total_w = CUBE_SIZE
	var total_h = float(valor_maximo) * CUBE_SIZE
	
	# Sombra projetada no chão
	var shadow_rect = Rect2(-total_w * 0.5, total_h * 0.5 - 4.0, total_w, 14.0)
	draw_rect(shadow_rect, Color(0, 0, 0, 0.2), true, 7.0)
	
	# Fator de iluminação baseado no progresso de toques:
	# 0 toques: escurecido (0.42)
	# intermediário: clareando gradativamente
	# totalmente acordado: 1.0 (cor cheia e vibrante)
	var progress = float(toques_atuais) / float(valor_maximo)
	var light_factor = 1.0 if is_awake else lerpf(0.42, 0.85, progress)
	
	# Desenha os cubos empilhados
	for i in range(valor_maximo):
		var y_offset = -total_h * 0.5 + float(i) * CUBE_SIZE + CUBE_SIZE * 0.5
		var cube_rect = Rect2(Vector2(-CUBE_SIZE * 0.5, y_offset - CUBE_SIZE * 0.5), Vector2(CUBE_SIZE, CUBE_SIZE))
		var base_color = _get_block_color()
		var render_color = base_color * light_factor
		render_color.a = 1.0
		
		# Cubo principal
		draw_rect(cube_rect, render_color, true, 8.0)
		
		# Brilho superior
		var highlight_rect = Rect2(cube_rect.position.x + 4, cube_rect.position.y + 3, cube_rect.size.x - 8, 7)
		draw_rect(highlight_rect, Color(1, 1, 1, 0.28 * light_factor), true, 3.5)
		
		# Borda
		var border_color = render_color.darkened(0.25)
		draw_rect(cube_rect, border_color, false, 3.0, 8.0)
		
	# Pés do personagem
	var foot_color = Color("#2F3542") * light_factor
	foot_color.a = 1.0
	draw_rect(Rect2(-18, total_h * 0.5 - 3, 14, 8), foot_color, true, 4.0)
	draw_rect(Rect2(4, total_h * 0.5 - 3, 14, 8), foot_color, true, 4.0)
	
	# Rosto do personagem no cubo superior
	var head_y = -total_h * 0.5 + CUBE_SIZE * 0.5
	_draw_face(Vector2(0, head_y))
	
	# Efeito visual de sono (Zzz) se estiver dormindo
	if not is_awake:
		_draw_sleep_zzz(Vector2(total_w * 0.5 + 10, -total_h * 0.5))
	else:
		_draw_numberling_badge(-total_h * 0.5)
		
	# Balão de fala
	if speech_text != "":
		_draw_speech_bubble(-total_h * 0.5)

## Retorna a cor característica de cada número
func _get_block_color() -> Color:
	match valor_maximo:
		1:
			return Color("#FF3838") # Vermelho alegre do Bloco 1
		2:
			return Color("#FF851B") # Laranja brilhante do Bloco 2
		3:
			return Color("#FFDC00") # Amarelo radiante do Bloco 3
		_:
			return Color("#2ECC40")

## Desenha os olhos e boca (dormindo vs acordado)
func _draw_face(head_pos: Vector2) -> void:
	var face_color = Color("#2F3542")
	
	if not is_awake:
		# Olhos fechados / dormindo (linhas curvas suaves)
		var left_eye = head_pos + Vector2(-10, -2)
		var right_eye = head_pos + Vector2(10, -2)
		draw_arc(left_eye, 6.0, 0.1 * PI, 0.9 * PI, 8, face_color, 2.5)
		draw_arc(right_eye, 6.0, 0.1 * PI, 0.9 * PI, 8, face_color, 2.5)
		
		# Boquinha sonolenta pequena 'o'
		draw_circle(head_pos + Vector2(0, 10), 3.0, face_color)
	else:
		# Personagem acordado e feliz!
		if is_blinking:
			# Piscando
			draw_line(head_pos + Vector2(-16, -2), head_pos + Vector2(-4, -2), face_color, 3.0)
			draw_line(head_pos + Vector2(4, -2), head_pos + Vector2(16, -2), face_color, 3.0)
		else:
			if valor_maximo == 1:
				# Ciclope do 1
				draw_circle(head_pos + Vector2(0, -2), 12.0, Color.WHITE)
				draw_circle(head_pos + Vector2(0, -2), 12.0, face_color, false, 2.0)
				draw_circle(head_pos + Vector2(0, -2), 6.0, face_color)
				draw_circle(head_pos + Vector2(2, -4), 2.5, Color.WHITE)
			else:
				# Dois olhos
				for ex in [-10.0, 10.0]:
					var ep = head_pos + Vector2(ex, -2)
					draw_circle(ep, 8.0, Color.WHITE)
					draw_circle(ep, 8.0, face_color, false, 1.8)
					draw_circle(ep, 4.0, face_color)
					draw_circle(ep + Vector2(1.5, -1.5), 1.5, Color.WHITE)
					
		# Sorriso largo e feliz
		var smile_pts = PackedVector2Array()
		for s in range(9):
			var t = float(s) / 8.0
			var sx = lerpf(-12.0, 12.0, t)
			var sy = sin(t * PI) * 5.0
			smile_pts.append(head_pos + Vector2(sx, 9.0 + sy))
		draw_polyline(smile_pts, face_color, 2.8)

## Letrinhas 'Zzz' flutuantes enquanto dorme
func _draw_sleep_zzz(base_pos: Vector2) -> void:
	var font = _get_default_font()
	var z_items = [
		{ "size": 14, "offset": Vector2(0, -6 + sin(zzz_time * 2.5) * 4.0), "alpha": 0.8 },
		{ "size": 18, "offset": Vector2(14, -22 + sin(zzz_time * 2.5 + 1.0) * 5.0), "alpha": 0.9 },
		{ "size": 24, "offset": Vector2(30, -42 + sin(zzz_time * 2.5 + 2.0) * 6.0), "alpha": 1.0 }
	]
	
	for item in z_items:
		var col = Color(0.3, 0.45, 0.85, item.alpha)
		draw_string(font, base_pos + item.offset, "Z", HORIZONTAL_ALIGNMENT_LEFT, -1, item.size, col)

## Crachá/Número no topo da cabeça quando acordado
func _draw_numberling_badge(top_y: float) -> void:
	var badge_pos = Vector2(0, top_y - 20.0)
	var badge_size = Vector2(32.0, 32.0)
	var rect = Rect2(badge_pos - badge_size * 0.5, badge_size)
	
	draw_rect(rect, _get_block_color(), true, 8.0)
	draw_rect(rect, Color.WHITE, false, 2.5, 8.0)
	
	var font = _get_default_font()
	var text = str(valor_maximo)
	var text_sz = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, 18)
	draw_string(font, badge_pos + Vector2(-text_sz.x * 0.5, text_sz.y * 0.35), text, HORIZONTAL_ALIGNMENT_CENTER, -1, 18, Color.WHITE)

## Balão de fala
func _draw_speech_bubble(top_y: float) -> void:
	var font = _get_default_font()
	var font_size = 18
	var text_sz = font.get_string_size(speech_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	var bubble_w = text_sz.x + 32.0
	var bubble_h = 36.0
	var bubble_pos = Vector2(0, top_y - 62.0)
	var rect = Rect2(bubble_pos - Vector2(bubble_w * 0.5, bubble_h * 0.5), Vector2(bubble_w, bubble_h))
	
	draw_rect(rect, Color.WHITE, true, 10.0)
	draw_rect(rect, Color("#2F3542"), false, 2.5, 10.0)
	
	var tip = [
		bubble_pos + Vector2(-5, bubble_h * 0.5),
		bubble_pos + Vector2(5, bubble_h * 0.5),
		bubble_pos + Vector2(0, bubble_h * 0.5 + 7)
	]
	draw_colored_polygon(PackedVector2Array(tip), Color.WHITE)
	draw_polyline(PackedVector2Array([tip[0], tip[2], tip[1]]), Color("#2F3542"), 2.2)
	draw_string(font, bubble_pos + Vector2(-text_sz.x * 0.5, text_sz.y * 0.35), speech_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color("#2F3542"))

func _get_default_font() -> Font:
	if ThemeDB and "fallback_font" in ThemeDB and ThemeDB.fallback_font:
		return ThemeDB.fallback_font
	return ThemeDB.get_fallback_font()
