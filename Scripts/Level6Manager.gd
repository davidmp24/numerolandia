extends Node2D
class_name Level6Manager

## Level6Manager: Controlador da "Fase 6: O Túnel de Crescimento" (Adição e Comparação de Alturas)
## Foco Pedagógico: Adição Dirigida a Objetivo (2 + 4 = 6) e Feedback Construtivo sem Punição

# Referências a nós da cena
@onready var level_manager: LevelManager = $LevelManager
@export var next_scene_path: String = "res://Scenes/Level7_HeavyRocket.tscn"

# Elementos do Túnel e Cenário
@onready var tunnel_entrance: Marker2D = $GrowthTunnel/EntrancePoint
@onready var tunnel_exit: Marker2D = $GrowthTunnel/ExitPoint
@onready var height_meter: Node2D = $GrowthTunnel/HeightMeter

# Personagem principal e plataforma de blocos
var character_block: NumberBlock = null
var is_processing_merge: bool = false
var is_level_completed: bool = false

# Posições originais da plataforma de seleção
const PLATFORM_POSITIONS = {
	3: Vector2(1100, 880),
	4: Vector2(1350, 880),
	5: Vector2(1600, 880)
}

func _ready() -> void:
	# Configuração de Metadados e Objetivos no HUD
	if level_manager:
		level_manager.level_title = "Fase 6: O Túnel de Crescimento (2 + 4 = 6)"
		level_manager.level_objective = "A máquina só aceita tamanho 6! Escolha o bloco certo para crescer o Dois!"
		level_manager.next_scene_path = next_scene_path
		
	_setup_character_two()
	_spawn_selection_blocks()
	
	# Narração inicial acolhedora após 0.8s
	await get_tree().create_timer(0.8).timeout
	if AudioManager:
		AudioManager.speak("O Dois precisa atravessar a máquina de tamanho Seis! Qual bloco devemos juntar a ele?")

## Instancia o Bloco 2 na entrada do túnel
func _setup_character_two() -> void:
	var block_scene = preload("res://Scenes/NumberBlock.tscn")
	if not character_block:
		character_block = block_scene.instantiate() as NumberBlock
		character_block.value = 2
		character_block.position = Vector2(450, 680)
		character_block.can_split = false
		add_child(character_block)
		
	# Conecta o evento de fusão
	if not character_block.merged_with.is_connected(_on_character_merged):
		character_block.merged_with.connect(_on_character_merged)

## Instancia os 3 blocos de escolha (3, 4 e 5) na plataforma
func _spawn_selection_blocks() -> void:
	var block_scene = preload("res://Scenes/NumberBlock.tscn")
	for val in [3, 4, 5]:
		var b = block_scene.instantiate() as NumberBlock
		b.value = val
		b.position = PLATFORM_POSITIONS[val]
		b.can_split = false
		add_child(b)

## Evento disparado quando um bloco é fundido ao personagem
func _on_character_merged(consumed_block: NumberBlock, resulting_value: int) -> void:
	if is_processing_merge or is_level_completed:
		return
		
	is_processing_merge = true
	var added_value = consumed_block.value
	
	# Localiza a nova instância do personagem fundido
	await get_tree().create_timer(0.15).timeout
	var blocks_in_scene = get_tree().get_nodes_in_group("number_blocks")
	for b in blocks_in_scene:
		if b is NumberBlock and b.value == resulting_value:
			character_block = b
			break
			
	if not character_block:
		is_processing_merge = false
		return
		
	# Desativa arraste temporário durante a validação
	character_block.input_pickable = false
	
	if resulting_value == 6:
		# ACERTO (2 + 4 = 6): Sucesso pedagógico
		_handle_success_validation()
	else:
		# ERRO PEDAGÓGICO (2 + 3 = 5 ou 2 + 5 = 7): Tratamento suave
		_handle_error_validation(resulting_value, added_value)

## Validação de Sucesso: O Bloco 6 atravessa o túnel e completa a fase
func _handle_success_validation() -> void:
	is_level_completed = true
	
	# Feedback sonoro da operação
	if AudioManager:
		AudioManager.play_operation_narrator("4 + 2 = 6")
		
	character_block.show_speech("Dois mais quatro é igual a Seis! Perfeito!", 3.0)
	
	# Animação do medidor do túnel acendendo em verde
	if height_meter:
		var tw_meter = height_meter.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw_meter.tween_property(height_meter, "modulate", Color("#2ED573"), 0.3)
		tw_meter.parallel().tween_property(height_meter, "scale", Vector2(1.2, 1.2), 0.2)
		tw_meter.tween_property(height_meter, "scale", Vector2(1.0, 1.0), 0.2)
		
	await get_tree().create_timer(0.8).timeout
	
	# Animação do Bloco 6 atravessando o túnel alegremente
	var tw_run = character_block.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	var exit_x = tunnel_exit.global_position.x if tunnel_exit else 1650.0
	tw_run.tween_property(character_block, "position:x", exit_x, 1.5)
	
	if AudioManager:
		AudioManager.play_victory_sound()
		
	await tw_run.finished
	
	# Libera a tela de vitória
	if level_manager:
		level_manager.trigger_victory("Parabéns! Dois mais quatro é igual a Seis, e o bloco atravessou o túnel!")

## Tratamento de Erro Construtivo: Pausa pedagógica de 1.5s, expressão de dúvida e split seguro
func _handle_error_validation(wrong_value: int, added_value: int) -> void:
	# Feedback sonoro amigável de erro
	if AudioManager:
		AudioManager.play_oops_too_big()
		
	# Medidor acende com luz de aviso amigável
	if height_meter:
		var tw_meter = height_meter.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw_meter.tween_property(height_meter, "modulate", Color("#FF4757"), 0.2)
		tw_meter.tween_property(height_meter, "modulate", Color.WHITE, 0.4)
		
	character_block.show_speech("Ainda não dá! Preciso do tamanho Seis!", 2.8)
	
	# Animação de tremor de confusão / dúvida
	var tw_confused = character_block.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw_confused.tween_property(character_block, "rotation_degrees", -8.0, 0.08)
	tw_confused.tween_property(character_block, "rotation_degrees", 8.0, 0.08)
	tw_confused.tween_property(character_block, "rotation_degrees", 0.0, 0.08)
	
	# REGRA OBRIGATÓRIA: Tempo pedagógico de 1.5s para a criança processar visualmente a diferença de tamanho
	await get_tree().create_timer(1.5).timeout
	
	# Ejeção do bloco incorreto (Split de restauração)
	_eject_wrong_block_and_reset(added_value)

## Separa o bloco adicionado, devolvendo-o para a plataforma e restaurando o Bloco 2
func _eject_wrong_block_and_reset(added_value: int) -> void:
	var current_pos = character_block.global_position
	character_block.queue_free()
	
	var block_scene = preload("res://Scenes/NumberBlock.tscn")
	
	# 1. Restaura o Bloco 2 na posição do personagem
	character_block = block_scene.instantiate() as NumberBlock
	character_block.value = 2
	character_block.position = current_pos
	character_block.can_split = false
	add_child(character_block)
	
	# Conecta novamente o sinal de fusão
	character_block.merged_with.connect(_on_character_merged)
	
	# 2. Devolve o bloco incorreto saltando de volta para a sua plataforma
	var returned_block = block_scene.instantiate() as NumberBlock
	returned_block.value = added_value
	returned_block.position = current_pos + Vector2(60, -20)
	returned_block.can_split = false
	add_child(returned_block)
	
	var target_pos = PLATFORM_POSITIONS.get(added_value, Vector2(1350, 880))
	var tw_return = returned_block.create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tw_return.tween_property(returned_block, "position", target_pos, 0.6)
	
	if AudioManager:
		AudioManager.play_split_sound()
		AudioManager.speak("Tente outro bloco para somar Seis!")
		
	await tw_return.finished
	is_processing_merge = false
