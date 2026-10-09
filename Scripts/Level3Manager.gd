extends Node2D
class_name Level3Manager

## Level3Manager: Controlador da "Fase 3: A Árvore de Maçãs" (Somas até 5)
## Foco Pedagógico: Adição Concreta (2 + 3 = 5) e Altura Visual para Crianças de 4 anos

# Referências a nós da cena
@onready var level_manager: LevelManager = $LevelManager
@export var next_scene_path: String = "res://Scenes/Level4_MagicScale.tscn"

# Elementos interativos do cenário
@onready var apple_tree: Node2D = $AppleTree
@onready var apple: Node2D = $AppleTree/Apple
@onready var apple_target_marker: Marker2D = $AppleTree/AppleTargetHeight

# Controle de Blocos e Estados
var block_3: NumberBlock = null
var block_2: NumberBlock = null
var block_1: NumberBlock = null
var block_5: NumberBlock = null

var is_merging: bool = false
var is_victory_triggered: bool = false
var jump_tween: Tween = null

func _ready() -> void:
	# Configuração do HUD e Narrador da Missão
	if level_manager:
		level_manager.level_title = "Fase 3: A Árvore de Maçãs (2 + 3 = 5)"
		level_manager.level_objective = "O Bloco 3 não alcança a maçã sozinho! Junte o Bloco 2 com o 3 para formar o 5!"
		level_manager.next_scene_path = next_scene_path
		
	_setup_scene_blocks()
	_start_block3_hop_loop()
	
	# Narração inicial acolhedora após 0.8s
	await get_tree().create_timer(0.8).timeout
	if AudioManager:
		AudioManager.speak("O Três está tentando pegar a maçã, mas é baixinho! Junte o Dois com o Três para formar o Cinco!")

## Localiza ou instancia os blocos iniciais (Bloco 3 saltando, Bloco 2 e Bloco 1 no chão)
func _setup_scene_blocks() -> void:
	var block_scene = preload("res://Scenes/NumberBlock.tscn")
	
	# Se já houver blocos na cena, coleta as referências
	var blocks_in_scene = get_tree().get_nodes_in_group("number_blocks")
	for b in blocks_in_scene:
		if b is NumberBlock:
			if b.value == 3:
				block_3 = b
			elif b.value == 2:
				block_2 = b
			elif b.value == 1:
				block_1 = b
				
	# Se não existirem na cena, instancia proceduralmente
	if not block_3:
		block_3 = block_scene.instantiate() as NumberBlock
		block_3.value = 3
		block_3.position = Vector2(960, 680)
		add_child(block_3)
		
	if not block_2:
		block_2 = block_scene.instantiate() as NumberBlock
		block_2.value = 2
		block_2.position = Vector2(480, 700)
		add_child(block_2)
		
	if not block_1:
		block_1 = block_scene.instantiate() as NumberBlock
		block_1.value = 1
		block_1.position = Vector2(280, 720)
		add_child(block_1)
		
	# Conecta os sinais de fusão dos blocos
	_connect_merge_signals()

func _connect_merge_signals() -> void:
	var blocks_in_scene = get_tree().get_nodes_in_group("number_blocks")
	for b in blocks_in_scene:
		if b is NumberBlock:
			if not b.merged_with.is_connected(_on_block_merged):
				b.merged_with.connect(_on_block_merged)

## Animação em loop do Bloco 3 tentando pular para pegar a maçã (sem sucesso)
func _start_block3_hop_loop() -> void:
	if not is_instance_valid(block_3) or is_merging:
		return
		
	var original_y = block_3.position.y
	jump_tween = create_tween().set_loops().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Pulo curto do 3 (alcança apenas y - 45px, longe da maçã no topo)
	jump_tween.tween_property(block_3, "position:y", original_y - 45.0, 0.35)
	jump_tween.chain().tween_property(block_3, "position:y", original_y, 0.3).set_ease(Tween.EASE_IN)
	jump_tween.chain().tween_interval(0.9)

## Callback acionado quando ocorre a fusão de blocos
func _on_block_merged(other_block: NumberBlock, resulting_value: int) -> void:
	if is_merging or is_victory_triggered:
		return
		
	# Caso resulte no Bloco 5 (ex: 2 + 3 = 5 ou 1 + 4 = 5)
	if resulting_value == 5:
		_handle_block5_formed()

## Trata a criação do Bloco 5 e a colheita automática da maçã
func _handle_block5_formed() -> void:
	is_merging = true
	
	# Para o loop de pulo do Bloco 3
	if jump_tween and jump_tween.is_running():
		jump_tween.kill()
		
	# Localiza o Bloco 5 recém-instanciado
	await get_tree().create_timer(0.2).timeout
	var blocks_in_scene = get_tree().get_nodes_in_group("number_blocks")
	for b in blocks_in_scene:
		if b is NumberBlock and b.value == 5:
			block_5 = b
			break
			
	if not block_5:
		return
		
	# Desativa arraste temporário durante a animação de vitória
	block_5.input_pickable = false
	
	# Instancia partículas mágicas no Bloco 5
	_spawn_magic_particles(block_5.global_position)
	
	# Áudio pedagógico sincronizado: "Dois mais três é igual a Cinco!"
	if AudioManager:
		AudioManager.play_operation_narrator("3 + 2 = 5")
		
	block_5.show_speech("Dois mais três é igual a Cinco! Agora eu alcanço!", 3.0)
	
	await get_tree().create_timer(1.2).timeout
	
	# Animação do Bloco 5 alcançando a maçã na árvore com pulo elástico
	_animate_block5_reaches_apple()

## Animação do Bloco 5 colhendo a maçã na altura 5
func _animate_block5_reaches_apple() -> void:
	if not is_instance_valid(block_5):
		return
		
	var target_x = 960.0
	var ground_y = 660.0
	
	# 1. Posiciona o Bloco 5 sob a macieira
	var tw_move = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw_move.tween_property(block_5, "position:x", target_x, 0.4)
	await tw_move.finished
	
	# 2. Pulo triunfante até o galho da maçã
	var tw_reach = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw_reach.tween_property(block_5, "position:y", ground_y - 120.0, 0.45)
	tw_reach.parallel().tween_property(block_5, "scale", Vector2(1.1, 1.3), 0.45)
	
	await tw_reach.finished
	
	# 3. A maçã se solta do galho e cai feliz no topo do Bloco 5
	if is_instance_valid(apple):
		var tw_apple = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tw_apple.tween_property(apple, "position:y", apple.position.y + 110.0, 0.5)
		tw_apple.parallel().tween_property(apple, "scale", Vector2(1.25, 1.25), 0.2)
		
	if AudioManager:
		AudioManager.play_victory_sound()
		
	# 4. Aterrissagem comemoração
	var tw_land = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw_land.tween_property(block_5, "position:y", ground_y, 0.4)
	tw_land.parallel().tween_property(block_5, "scale", Vector2(1.0, 1.0), 0.4)
	
	await tw_land.finished
	_spawn_magic_particles(apple.global_position if is_instance_valid(apple) else block_5.global_position)
	block_5.show_speech("Hummm, que maçã deliciosa! Sou o Cinco!", 3.0)
	
	await get_tree().create_timer(1.0).timeout
	
	# Dispara a vitória e o botão da próxima fase
	is_victory_triggered = true
	if level_manager:
		level_manager.trigger_victory("Parabéns! Dois mais três é igual a Cinco, e você alcançou a maçã!")

## Emite partículas de brilho mágico
func _spawn_magic_particles(pos: Vector2) -> void:
	var part = CPUParticles2D.new()
	part.position = pos
	part.emitting = true
	part.amount = 30
	part.lifetime = 0.8
	part.one_shot = true
	part.explosiveness = 0.85
	part.spread = 180.0
	part.initial_velocity_min = 80.0
	part.initial_velocity_max = 160.0
	part.scale_amount_min = 5.0
	part.scale_amount_max = 10.0
	part.color = Color("#FFDC00")
	add_child(part)
	get_tree().create_timer(1.2).timeout.connect(part.queue_free)
