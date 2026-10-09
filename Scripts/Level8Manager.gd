extends Node2D
class_name Level8Manager

## Level8Manager: Controlador da "Fase 8: A Caverna Estreita" (Divisão por Metades 8 / 2 = 4)
## Foco Pedagógico: Divisão Prática em Metades e Encaixe de Silhuetas para Crianças de 4 anos

# Referências a nós da cena
@onready var level_manager: LevelManager = $LevelManager
@export var next_scene_path: String = "res://Scenes/MainMenu.tscn"

# Elementos da Caverna e Cenário
@onready var cave_entrance: Node2D = $NarrowCave/Entrance
@onready var cave_door: Node2D = $NarrowCave/StoneDoor
@onready var cave_button_area: Area2D = $NarrowCave/ButtonArea

# Referência aos Blocos
var initial_block_8: NumberBlock = null
var is_cave_door_opened: bool = false
var is_processing_math: bool = false

func _ready() -> void:
	# Configuração do HUD e Narrador da Missão
	if level_manager:
		level_manager.level_title = "Fase 8: A Caverna Estreita (8 / 2 = 4)"
		level_manager.level_objective = "O Superócto é muito alto para entrar! Dê dois toques rápidos para dividi-lo em dois!"
		level_manager.next_scene_path = next_scene_path
		
	_setup_initial_block_eight()
	_setup_cave_button()
	
	# Narração pedagógica inicial após 0.8s
	await get_tree().create_timer(0.8).timeout
	if AudioManager:
		AudioManager.speak("A caverna é baixinha! Dê dois toques no Oito para dividi-lo ao meio!")

## Instancia o Bloco 8 inicial com suporte ao duplo toque
func _setup_initial_block_eight() -> void:
	var block_scene = preload("res://Scenes/NumberBlock.tscn")
	if not initial_block_8:
		initial_block_8 = block_scene.instantiate() as NumberBlock
		initial_block_8.value = 8
		initial_block_8.position = Vector2(480, 680)
		initial_block_8.can_split = true
		add_child(initial_block_8)
		
	# Conecta ao sinal de divisão do bloco
	initial_block_8.split_performed.connect(_on_eight_split_performed)

## Configura o botão / placa de pressão no interior da caverna
func _setup_cave_button() -> void:
	if cave_button_area:
		cave_button_area.area_entered.connect(_on_cave_button_area_entered)

## Evento disparado quando o Bloco 8 se divide em dois blocos 4
func _on_eight_split_performed() -> void:
	if is_processing_math:
		return
	is_processing_math = true
	
	# Fala do narrador explicando a metade
	if AudioManager:
		AudioManager.speak("Oito se dividiu em dois Quatro!")
		
	await get_tree().create_timer(0.4).timeout
	
	# Conecta todos os blocos 4 para validação de entrada na caverna
	var blocks_in_scene = get_tree().get_nodes_in_group("number_blocks")
	for b in blocks_in_scene:
		if b is NumberBlock and b.value == 4:
			b.show_speech("Agora eu caibo na caverna!", 2.5)
			
	await get_tree().create_timer(1.2).timeout
	is_processing_math = false

## Evento quando um bloco entra na área do botão dentro da caverna
func _on_cave_button_area_entered(area: Area2D) -> void:
	if is_cave_door_opened or not (area is NumberBlock):
		return
		
	var nb = area as NumberBlock
	if nb.value == 4:
		# Acerto: O bloco 4 aciona o botão e abre a caverna
		_open_cave_door(nb)
	elif nb.value > 4:
		# Bloco muito grande para a entrada
		nb.show_speech("Sou muito grande para entrar aqui!", 2.0)
		if AudioManager:
			AudioManager.play_oops_too_big()

## Animação de abertura triunfante da porta de pedra da caverna
func _open_cave_door(block: NumberBlock) -> void:
	is_cave_door_opened = true
	
	# Desativa arraste no bloco que acionou o botão
	block.input_pickable = false
	
	# Animação de encaixe exato no botão
	var tw_snap = block.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var btn_pos = cave_button_area.global_position if cave_button_area else Vector2(1200, 680)
	tw_snap.tween_property(block, "global_position", btn_pos, 0.3)
	
	_spawn_cave_sparkles(btn_pos)
	if AudioManager:
		AudioManager.play_victory_sound()
		
	await tw_snap.finished
	
	# Animação da porta de pedra subindo
	if is_instance_valid(cave_door):
		var tw_door = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tw_door.tween_property(cave_door, "position:y", cave_door.position.y - 280.0, 1.0)
		await tw_door.finished
		
	await get_tree().create_timer(0.6).timeout
	
	# Dispara vitória final do módulo
	if level_manager:
		level_manager.trigger_victory("Parabéns! Oito se dividiu em dois Quatro, e o caminho da caverna foi liberado!")

## Partículas luminosas de sucesso no botão
func _spawn_cave_sparkles(pos: Vector2) -> void:
	var part = CPUParticles2D.new()
	part.position = pos
	part.emitting = true
	part.amount = 30
	part.lifetime = 0.8
	part.one_shot = true
	part.explosiveness = 0.9
	part.spread = 180.0
	part.initial_velocity_min = 70.0
	part.initial_velocity_max = 150.0
	part.color = Color("#2ED573")
	add_child(part)
	get_tree().create_timer(1.2).timeout.connect(part.queue_free)
