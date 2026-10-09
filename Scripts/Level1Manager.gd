extends Node2D
class_name Level1Manager

## Level1Manager: Controlador da "Fase 1: Acorde os Blocos" (O Jardim das Quantidades)
## Foco Pedagógico: Subitização e Correspondência Biunívoca para Crianças de 4 anos

# Referências a nós da cena
@onready var level_manager: LevelManager = $LevelManager
@export var next_scene_path: String = "res://Scenes/Level3_AppleTree.tscn"

# Lista de blocos dorminhocos e controle de vitória
@export var blocks: Array[SleepingBlock] = []
var total_blocks: int = 3
var awakened_count: int = 0
var is_level_finished: bool = false

func _ready() -> void:
	# Configuração de Metadados e Objetivos Pedagógicos no HUD
	if level_manager:
		level_manager.level_title = "Fase 1: Acorde os Blocos"
		level_manager.level_objective = "Toque nos bloquinhos dorminhocos para acordá-los! Conte cada toque!"
		level_manager.next_scene_path = next_scene_path
		
	# Inicialização dos blocos e conexões dos Sinais Nativos do Godot 4
	_setup_sleeping_blocks()
	
	# Narração inicial acolhedora após 0.8s
	await get_tree().create_timer(0.8).timeout
	if AudioManager:
		AudioManager.speak("Toque nos bloquinhos para acordá-los! Conte cada toque até despertarem!")

## Localiza ou instancia os 3 blocos dorminhocos (1, 2 e 3) e conecta os sinais
func _setup_sleeping_blocks() -> void:
	# Coleta blocos existentes no grupo ou cria dinamicamente se necessário
	var found_blocks = get_tree().get_nodes_in_group("sleeping_blocks")
	
	if found_blocks.size() > 0:
		blocks.clear()
		for b in found_blocks:
			if b is SleepingBlock:
				blocks.append(b)
	else:
		# Criação procedural e posicionamento dos 3 blocos no Jardim das Quantidades
		_spawn_default_blocks()
		
	total_blocks = blocks.size()
	
	# Conecta os sinais de cada bloco
	for block in blocks:
		if not block.block_awakened.is_connected(_on_block_awakened):
			block.block_awakened.connect(_on_block_awakened)

## Instancia os 3 blocos dorminhocos com espaçamento amplo para toques infantis
func _spawn_default_blocks() -> void:
	var positions = [
		Vector2(550, 680),  # Bloco 1 (1 toque)
		Vector2(960, 660),  # Bloco 2 (2 toques)
		Vector2(1370, 630)  # Bloco 3 (3 toques)
	]
	
	for i in range(3):
		var val = i + 1
		var sb = SleepingBlock.new()
		sb.valor_maximo = val
		sb.position = positions[i]
		add_child(sb)
		blocks.append(sb)

## Resposta ao sinal nativo block_awakened emitido por um SleepingBlock
func _on_block_awakened(block: SleepingBlock, value: int) -> void:
	awakened_count += 1
	
	# Pequena celebração visual individual
	_spawn_mini_sparkles(block.global_position)
	
	# Checagem da Condição de Vitória (todos os 3 blocos despertos)
	if awakened_count >= total_blocks and not is_level_finished:
		_trigger_phase_victory()

## Aciona o encerramento vitorioso, confetes e liberação da próxima fase
func _trigger_phase_victory() -> void:
	is_level_finished = true
	
	# Aguarda a última fala e pulo elástico terminarem
	await get_tree().create_timer(0.6).timeout
	
	# Instancia chuva comemorativa de confetes na tela
	_spawn_confetti_shower()
	
	# Efeito sonoro festivo
	if AudioManager:
		AudioManager.play_victory_sound()
		
	await get_tree().create_timer(0.5).timeout
	
	# Libera a tela de vitória com o botão grande de avançar
	if level_manager:
		level_manager.trigger_victory("Parabéns! Você acordou o Um, o Dois e o Três contando cada toque!")

## Instancia partículas de confetes coloridos caindo pela tela
func _spawn_confetti_shower() -> void:
	var confetti = CPUParticles2D.new()
	confetti.position = Vector2(960, -20)
	confetti.emitting = true
	confetti.amount = 90
	confetti.lifetime = 3.5
	confetti.one_shot = false
	confetti.explosiveness = 0.15
	confetti.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	confetti.emission_rect_extents = Vector2(960, 10)
	
	# Física e dispersão
	confetti.direction = Vector2(0, 1)
	confetti.spread = 25.0
	confetti.gravity = Vector2(0, 220)
	confetti.initial_velocity_min = 120.0
	confetti.initial_velocity_max = 280.0
	confetti.angular_velocity_min = -180.0
	confetti.angular_velocity_max = 180.0
	confetti.scale_amount_min = 7.0
	confetti.scale_amount_max = 14.0
	
	# Gradiente de cores vibrantes e infantis
	var grad = Gradient.new()
	grad.set_color(0, Color("#FF3838"))
	grad.add_point(0.2, Color("#FF851B"))
	grad.add_point(0.4, Color("#FFDC00"))
	grad.add_point(0.6, Color("#2ED573"))
	grad.add_point(0.8, Color("#1E90FF"))
	grad.add_point(1.0, Color("#9B59B6"))
	confetti.color_ramp = grad
	
	add_child(confetti)

## Efeito de brilho estelar ao redor de um bloco recém-desperto
func _spawn_mini_sparkles(pos: Vector2) -> void:
	var sparkles = CPUParticles2D.new()
	sparkles.position = pos
	sparkles.emitting = true
	sparkles.amount = 25
	sparkles.lifetime = 0.8
	sparkles.one_shot = true
	sparkles.explosiveness = 0.9
	sparkles.spread = 180.0
	sparkles.gravity = Vector2(0, 80)
	sparkles.initial_velocity_min = 80.0
	sparkles.initial_velocity_max = 160.0
	sparkles.scale_amount_min = 4.0
	sparkles.scale_amount_max = 8.0
	sparkles.color = Color("#FFFA65")
	
	add_child(sparkles)
	get_tree().create_timer(1.2).timeout.connect(sparkles.queue_free)
