extends Node2D
class_name Level5Manager

## Level5Manager: Controlador da "Fase 5: A Gangorra Injusta" (Conceito de Diferença e Comparação)
## Foco Pedagógico: Noção de Diferença Visual (7 - 5 = 2) e Equivalência para Crianças de 4 anos

# Máquina de Estados Simples para controle de fluxo e imunidade a inputs múltiplos
enum State { UNBALANCED, BALANCING, EQUAL }
var current_state: State = State.UNBALANCED

# Referências a nós da cena
@onready var level_manager: LevelManager = $LevelManager
@export var next_scene_path: String = "res://Scenes/Level6_GrowthTunnel.tscn"

# Elementos da Gangorra
@onready var seesaw_beam: Node2D = $Seesaw/Beam
@onready var left_seat: Node2D = $Seesaw/Beam/LeftSeat
@onready var right_seat: Node2D = $Seesaw/Beam/RightSeat

# Personagens nos assentos da gangorra
var block_7_left: NumberBlock = null
var block_5_right: NumberBlock = null

# Fantasmas posicionados acima do Bloco 5
var ghost_1: GhostBlock = null
var ghost_2: GhostBlock = null
var filled_ghosts_count: int = 0

func _ready() -> void:
	# Configuração de Metadados e Objetivos no HUD
	if level_manager:
		level_manager.level_title = "Fase 5: A Gangorra Injusta (7 - 5 = 2)"
		level_manager.level_objective = "O Sete é mais pesado que o Cinco! Encontre a diferença para equilibrar!"
		level_manager.next_scene_path = next_scene_path
		
	# Inicialização dos personagens e da gangorra
	_setup_seesaw_characters()
	_setup_ghost_blocks()
	_spawn_neutral_one_blocks()
	
	# Inclina a gangorra para o lado do 7 (-18 graus)
	if seesaw_beam:
		seesaw_beam.rotation_degrees = -18.0
		
	# Narração pedagógica inicial após 0.8s
	await get_tree().create_timer(0.8).timeout
	if AudioManager:
		AudioManager.speak("O Sete é maior! Qual é a diferença? Encaixe os bloquinhos para descobrir!")

func _process(_delta: float) -> void:
	# Mantém a rotação global dos assentos e blocos sempre na vertical (0 graus)
	if is_instance_valid(left_seat):
		left_seat.global_rotation = 0.0
	if is_instance_valid(right_seat):
		right_seat.global_rotation = 0.0

## Instancia o Bloco 7 no lado esquerdo e o Bloco 5 no lado direito da gangorra
func _setup_seesaw_characters() -> void:
	var block_scene = preload("res://Scenes/NumberBlock.tscn")
	
	# Bloco 7 no assento esquerdo
	if not block_7_left and left_seat:
		block_7_left = block_scene.instantiate() as NumberBlock
		block_7_left.value = 7
		block_7_left.position = Vector2(0, -30)
		block_7_left.input_pickable = false
		block_7_left.can_split = false
		left_seat.add_child(block_7_left)
		
	# Bloco 5 no assento direito
	if not block_5_right and right_seat:
		block_5_right = block_scene.instantiate() as NumberBlock
		block_5_right.value = 5
		block_5_right.position = Vector2(0, -30)
		block_5_right.input_pickable = false
		block_5_right.can_split = false
		right_seat.add_child(block_5_right)

## Posiciona os dois fantasmas translúcidos acima da cabeça do Bloco 5
func _setup_ghost_blocks() -> void:
	if not right_seat:
		return
		
	# Cada cubo tem CUBE_SIZE = 46.0. O Bloco 5 tem altura 5 cubos (~230px).
	# Os 2 fantasmas ficam empilhados acima da cabeça do 5 indicando a altura que falta para chegar a 7.
	ghost_1 = GhostBlock.new()
	ghost_1.ghost_index = 1
	ghost_1.position = Vector2(0, -170)
	ghost_1.ghost_filled.connect(_on_ghost_filled)
	right_seat.add_child(ghost_1)
	
	ghost_2 = GhostBlock.new()
	ghost_2.ghost_index = 2
	ghost_2.position = Vector2(0, -218)
	ghost_2.ghost_filled.connect(_on_ghost_filled)
	right_seat.add_child(ghost_2)

## Instancia blocos neutros '1' no chão para a criança arrastar
func _spawn_neutral_one_blocks() -> void:
	var block_scene = preload("res://Scenes/NumberBlock.tscn")
	var positions = [Vector2(450, 880), Vector2(650, 880), Vector2(1350, 880), Vector2(1550, 880)]
	
	for pos in positions:
		var b = block_scene.instantiate() as NumberBlock
		b.value = 1
		b.position = pos
		add_child(b)

## Trata o encaixe de cada bloco fantasma (Correspondência Biunívoca)
func _on_ghost_filled(index: int, placed_block: NumberBlock) -> void:
	if current_state != State.UNBALANCED:
		return
		
	filled_ghosts_count += 1
	
	# Feedback sonoro e verbal de contagem
	match filled_ghosts_count:
		1:
			if AudioManager:
				AudioManager.speak("Um...")
				AudioManager.play_synth_note(1)
			if is_instance_valid(placed_block):
				placed_block.show_speech("Um...", 1.2)
		2:
			if AudioManager:
				AudioManager.speak("Dois!")
				AudioManager.play_synth_note(2)
			if is_instance_valid(placed_block):
				placed_block.show_speech("Dois!", 1.2)
				
	# Quando ambos os fantasmas estiverem preenchidos (diferença completa = 2)
	if filled_ghosts_count >= 2:
		_trigger_seesaw_equilibrium()

## Executa a fusão final, transformação no 7 e nivelamento da gangorra
func _trigger_seesaw_equilibrium() -> void:
	current_state = State.BALANCING
	
	await get_tree().create_timer(0.6).timeout
	
	# Efeito de partículas de arco-íris no lado direito
	_spawn_rainbow_particles(right_seat.global_position)
	if AudioManager:
		AudioManager.play_merge_sound()
		
	# Remove os blocos fantasmas e o bloco 5
	if is_instance_valid(ghost_1):
		if ghost_1.filled_block:
			ghost_1.filled_block.queue_free()
		ghost_1.queue_free()
		
	if is_instance_valid(ghost_2):
		if ghost_2.filled_block:
			ghost_2.filled_block.queue_free()
		ghost_2.queue_free()
		
	if is_instance_valid(block_5_right):
		block_5_right.queue_free()
		
	# Instancia o novo Bloco 7 no assento direito
	var block_scene = preload("res://Scenes/NumberBlock.tscn")
	var new_block_7 = block_scene.instantiate() as NumberBlock
	new_block_7.value = 7
	new_block_7.position = Vector2(0, -30)
	new_block_7.scale = Vector2(0.2, 0.2)
	new_block_7.input_pickable = false
	new_block_7.can_split = false
	right_seat.add_child(new_block_7)
	
	# Animação de expansão e pulo triunfante do Bloco 7
	var tw_grow = new_block_7.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw_grow.tween_property(new_block_7, "scale", Vector2(1.2, 1.2), 0.25)
	tw_grow.tween_property(new_block_7, "scale", Vector2(1.0, 1.0), 0.2)
	
	# Animação de Nivelamento Suave da Gangorra (0 graus)
	var tw_seesaw = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw_seesaw.tween_property(seesaw_beam, "rotation_degrees", 0.0, 1.2)
	
	# Fala do narrador celebrando a equivalência
	if AudioManager:
		AudioManager.play_victory_sound()
		AudioManager.speak("A diferença é Dois! Sete é igual a Sete!")
		
	new_block_7.show_speech("Sete é igual a Sete!", 3.0)
	if is_instance_valid(block_7_left):
		block_7_left.show_speech("Somos iguais!", 3.0)
		
	await tw_seesaw.finished
	await get_tree().create_timer(0.8).timeout
	
	current_state = State.EQUAL
	
	# Dispara vitória e botão da próxima fase
	if level_manager:
		level_manager.trigger_victory("Parabéns! A diferença é Dois, e a gangorra ficou equilibrada!")

## Partículas de celebração coloridas
func _spawn_rainbow_particles(pos: Vector2) -> void:
	var part = CPUParticles2D.new()
	part.position = pos
	part.emitting = true
	part.amount = 40
	part.lifetime = 1.0
	part.one_shot = true
	part.explosiveness = 0.85
	part.spread = 180.0
	part.initial_velocity_min = 80.0
	part.initial_velocity_max = 180.0
	part.scale_amount_min = 6.0
	part.scale_amount_max = 12.0
	
	var grad = Gradient.new()
	grad.set_color(0, Color("#FF3838"))
	grad.add_point(0.2, Color("#FF851B"))
	grad.add_point(0.4, Color("#FFDC00"))
	grad.add_point(0.6, Color("#2ECC40"))
	grad.add_point(0.8, Color("#0074D9"))
	grad.add_point(1.0, Color("#8854D0"))
	part.color_ramp = grad
	
	add_child(part)
	get_tree().create_timer(1.5).timeout.connect(part.queue_free)
