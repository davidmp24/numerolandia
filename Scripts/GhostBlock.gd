extends Area2D
class_name GhostBlock

## GhostBlock: Bloco Fantasma Translúcido para Ensino de Diferença e Equivalência Visual
## Projeto: Numerolândia Kids (Módulo 3: Qual é a Diferença? - Fase 5)

# Sinais nativos do Godot 4
signal ghost_filled(ghost_index: int, placed_block: NumberBlock)

# Configurações do Fantasma
@export var ghost_index: int = 1 ## Ordem do fantasma (1º ou 2º)
var is_filled: bool = false       ## Indica se o espaço fantasma já foi ocupado por um bloco 1
var filled_block: NumberBlock = null

# Dimensões e Snap Magnético
const CUBE_SIZE: float = 46.0
const SNAP_DISTANCE: float = 50.0 ## Distância para o puxão magnético automático facilitando o toque

# Controle de Animação e Pulso
var pulse_time: float = 0.0
var glow_intensity: float = 0.5
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("ghost_blocks")
	pulse_time = randf() * TAU
	area_entered.connect(_on_area_entered)
	_setup_collision()
	queue_redraw()

func _process(delta: float) -> void:
	if not is_filled:
		pulse_time += delta * 3.5
		glow_intensity = 0.45 + sin(pulse_time) * 0.25
		queue_redraw()

## Configura o CollisionShape2D expandido para facilitar o encaixe
func _setup_collision() -> void:
	if not collision_shape:
		collision_shape = CollisionShape2D.new()
		add_child(collision_shape)
		
	var shape = RectangleShape2D.new()
	# Hitbox expandida para acolher toques imprecisos de crianças de 4 anos
	shape.size = Vector2(CUBE_SIZE * 1.5, CUBE_SIZE * 1.5)
	collision_shape.shape = shape

## Detecta quando um bloco entra na área do fantasma
func _on_area_entered(area: Area2D) -> void:
	if is_filled or not (area is NumberBlock):
		return
		
	var nb = area as NumberBlock
	# Só aceita blocos de valor 1 (diferença unitária)
	if nb.value != 1 or nb.is_destroyed:
		return
		
	if nb.is_dragging:
		# Conecta ao término do arraste para puxar o bloco para o fantasma no drop
		if not nb.dragged_end.is_connected(_on_block_dropped.bind(nb)):
			nb.dragged_end.connect(_on_block_dropped.bind(nb), CONNECT_ONE_SHOT)
	else:
		_snap_and_fill(nb)

## Callback disparado quando a criança solta o bloco próximo ao fantasma
func _on_block_dropped(block: NumberBlock) -> void:
	if is_filled or not is_instance_valid(block) or block.is_destroyed:
		return
		
	# Snap magnético: se soltou a menos de SNAP_DISTANCE ou dentro da área
	if global_position.distance_to(block.global_position) <= SNAP_DISTANCE + 40.0:
		_snap_and_fill(block)

## Executa o encaixe magnético com Tween e marca o fantasma como preenchido
func _snap_and_fill(block: NumberBlock) -> void:
	if is_filled or block.is_destroyed:
		return
		
	is_filled = true
	filled_block = block
	
	# Desativa arraste no bloco que agora está fixado no fantasma
	block.input_pickable = false
	block.can_split = false
	block.can_merge = false
	
	# Puxão magnético suave (Snap) com interpolação de Tween
	var tw = block.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(block, "global_position", global_position, 0.22)
	tw.parallel().tween_property(block, "scale", Vector2(1.1, 1.1), 0.12)
	tw.tween_property(block, "scale", Vector2(1.0, 1.0), 0.1)
	
	# Efeito visual de brilho e partículas de encaixe
	_spawn_snap_particles()
	
	# Atualiza o desenho do fantasma
	queue_redraw()
	
	# Emite o sinal para o Level5Manager processar a correspondência biunívoca
	emit_signal("ghost_filled", ghost_index, block)

## Desenho procedural do contorno fantasma pontilhado e translúcido
func _draw() -> void:
	var rect = Rect2(-CUBE_SIZE * 0.5, -CUBE_SIZE * 0.5, CUBE_SIZE, CUBE_SIZE)
	
	if not is_filled:
		# Fundo azul-celeste translúcido pulsante
		var bg_color = Color(0.3, 0.7, 1.0, glow_intensity * 0.35)
		draw_rect(rect, bg_color, true, 8.0)
		
		# Borda tracejada/brilhante de contorno
		var border_color = Color(1.0, 1.0, 1.0, glow_intensity + 0.2)
		draw_rect(rect, border_color, false, 3.5, 8.0)
		
		# Símbolo '?' ou '+' no centro do fantasma
		var font = _get_default_font()
		var text = "+"
		var sz = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, 24)
		draw_string(font, Vector2(-sz.x * 0.5, sz.y * 0.35), text, HORIZONTAL_ALIGNMENT_CENTER, -1, 24, Color(1, 1, 1, 0.7))
	else:
		# Brilho dourado de confirmação de encaixe
		draw_rect(rect, Color(1.0, 0.85, 0.2, 0.25), true, 8.0)

## Efeito de partículas cintilantes no momento do encaixe
func _spawn_snap_particles() -> void:
	var part = CPUParticles2D.new()
	part.position = Vector2.ZERO
	part.emitting = true
	part.amount = 18
	part.lifetime = 0.5
	part.one_shot = true
	part.explosiveness = 0.9
	part.spread = 180.0
	part.initial_velocity_min = 50.0
	part.initial_velocity_max = 110.0
	part.color = Color("#7BED9F")
	add_child(part)
	get_tree().create_timer(0.8).timeout.connect(part.queue_free)

func _get_default_font() -> Font:
	if ThemeDB and "fallback_font" in ThemeDB and ThemeDB.fallback_font:
		return ThemeDB.fallback_font
	return ThemeDB.get_fallback_font()
