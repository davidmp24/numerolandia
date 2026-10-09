extends Node2D
class_name MagicScale

## MagicScale: Lógica Matemática e Animação de Eixos da Balança Mágica
## Projeto: Numerolândia Kids (Módulo 2: O Poder de Juntar - Fase 4)

# Sinais nativos do Godot 4
signal peso_atualizado(novo_valor: int)
signal balanca_nivelada()
signal sobrecarga(peso_excesso: int)

# Configurações de Peso
@export var left_weight: int = 4
@export var right_weight: int = 1

# Referências de Nós e Geometria da Balança
@onready var beam: Node2D = $Beam
@onready var left_plate: Node2D = $Beam/LeftAnchor/LeftPlate
@onready var right_plate: Node2D = $Beam/RightAnchor/RightPlate
@onready var right_drop_zone: Area2D = $Beam/RightAnchor/RightPlate/DropZone

# Bloco atualmente assentado no prato direito
var current_right_block: NumberBlock = null
var current_left_block: NumberBlock = null

# Controle de Animação e Tween
var balance_tween: Tween = null
var is_locked: bool = false

func _ready() -> void:
	# Configura a DropZone do prato direito com hitbox expandida para touch infantil
	_setup_drop_zone()
	
	# Instancia o bloco 4 de referência no prato esquerdo se ainda não existir
	_setup_initial_blocks()
	
	# Atualiza a inclinação inicial sem animação brusca
	_apply_tilt(false)

func _process(_delta: float) -> void:
	# REGRA TÉCNICA OBRIGATÓRIA:
	# Mantém a rotação global dos pratos sempre em zero graus (0.0 rad)
	# para que os personagens e blocos fiquem sempre perfeitamente de pé!
	if is_instance_valid(left_plate):
		left_plate.global_rotation = 0.0
	if is_instance_valid(right_plate):
		right_plate.global_rotation = 0.0

## Inicializa a DropZone do prato direito para detecção de blocos soltos
func _setup_drop_zone() -> void:
	if right_drop_zone:
		if not right_drop_zone.area_entered.is_connected(_on_drop_zone_area_entered):
			right_drop_zone.area_entered.connect(_on_drop_zone_area_entered)

## Configura os blocos iniciais dos pratos (Bloco 4 na esquerda, Bloco 1 na direita)
func _setup_initial_blocks() -> void:
	var block_scene = load("res://Scenes/NumberBlock.tscn")
	if not block_scene:
		return
		
	# Bloco 4 no prato esquerdo (peso fixo de referência)
	if not current_left_block and left_plate:
		current_left_block = block_scene.instantiate() as NumberBlock
		current_left_block.value = left_weight
		current_left_block.position = Vector2(0, -25)
		current_left_block.can_split = false
		current_left_block.input_pickable = false # Fixo no prato esquerdo
		left_plate.add_child(current_left_block)
		
	# Bloco 1 inicial no prato direito
	if not current_right_block and right_plate:
		current_right_block = block_scene.instantiate() as NumberBlock
		current_right_block.value = right_weight
		current_right_block.position = Vector2(0, -25)
		current_right_block.can_split = false
		right_plate.add_child(current_right_block)

## Evento disparado quando um bloco arrastado pela criança entra na DropZone do prato direito
func _on_drop_zone_area_entered(area: Area2D) -> void:
	if is_locked or not (area is NumberBlock):
		return
		
	var incoming_block = area as NumberBlock
	# Ignora os blocos que já pertencem aos próprios pratos
	if incoming_block == current_right_block or incoming_block == current_left_block:
		return
		
	# Conecta ao término do arraste do bloco para realizar o merge assim que a criança soltá-lo
	if incoming_block.is_dragging:
		if not incoming_block.dragged_end.is_connected(_on_incoming_block_dropped.bind(incoming_block)):
			incoming_block.dragged_end.connect(_on_incoming_block_dropped.bind(incoming_block), CONNECT_ONE_SHOT)
	else:
		_process_block_merge_into_plate(incoming_block)

## Callback acionado quando a criança solta o bloco arrastado sobre o prato direito
func _on_incoming_block_dropped(incoming_block: NumberBlock) -> void:
	if is_locked or not is_instance_valid(incoming_block):
		return
		
	# Verifica se o bloco ainda está dentro ou próximo da área do prato direito (< 140px)
	var drop_center = right_plate.global_position
	if incoming_block.global_position.distance_to(drop_center) < 140.0:
		_process_block_merge_into_plate(incoming_block)

## Realiza a fusão do novo bloco com o bloco existente no prato direito
func _process_block_merge_into_plate(incoming_block: NumberBlock) -> void:
	if is_locked or not is_instance_valid(incoming_block) or incoming_block.is_destroyed:
		return
		
	is_locked = true
	incoming_block.is_destroyed = true
	
	var incoming_val = incoming_block.value
	var current_val = right_weight
	var resulting_val = current_val + incoming_val
	
	# Efeito visual de partículas no ponto do prato
	_spawn_sparkle_particles(right_plate.global_position)
	if AudioManager:
		AudioManager.play_merge_sound()
		
	# Remove o bloco arrastado e o bloco anterior do prato direito
	incoming_block.queue_free()
	if is_instance_valid(current_right_block):
		current_right_block.queue_free()
		
	# Instancia o novo bloco resultante assentado no prato direito
	var block_scene = load("res://Scenes/NumberBlock.tscn")
	current_right_block = block_scene.instantiate() as NumberBlock
	current_right_block.value = resulting_val
	current_right_block.position = Vector2(0, -25)
	current_right_block.scale = Vector2(0.3, 0.3)
	right_plate.add_child(current_right_block)
	
	# Animação de expansão e acomodação com Tween
	var tw = current_right_block.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(current_right_block, "scale", Vector2(1.2, 1.2), 0.18)
	tw.tween_property(current_right_block, "scale", Vector2(1.0, 1.0), 0.15)
	
	# Atualiza o peso e aplica a nova inclinação na balança
	right_weight = resulting_val
	emit_signal("peso_atualizado", right_weight)
	_apply_tilt(true)
	
	await tw.finished
	await get_tree().create_timer(0.4).timeout
	
	# Validação pedagógica do estado da balança
	_evaluate_balance_state(resulting_val, incoming_val)

## Avalia o estado da balança (Nivelada, Incompleta ou Sobrecarga)
func _evaluate_balance_state(resulting_val: int, _added_val: int) -> void:
	if resulting_val == left_weight:
		# SUCESSO: 4 é igual a 4! Balança perfeitamente nivelada
		if AudioManager:
			AudioManager.speak("Quatro é igual a Quatro!")
		emit_signal("balanca_nivelada")
		is_locked = false
		
	elif resulting_val > left_weight:
		# SOBRECARGA (Ex: 5 > 4): Tratamento gentil sem punição
		emit_signal("sobrecarga", resulting_val)
		_handle_overweight_rebound()
		
	else:
		# PROGRESSO INTERMEDIÁRIO (Ex: 1 + 1 = 2 ou 1 + 2 = 3)
		if AudioManager:
			AudioManager.speak("Agora temos %d no prato! Falta pouco para o Quatro!" % resulting_val)
		is_locked = false

## Trata a sobrecarga (peso > 4) de forma lúdica, suave e sem punição
func _handle_overweight_rebound() -> void:
	if AudioManager:
		AudioManager.play_oops_too_big()
		AudioManager.speak("Opa, ficou muito pesado!")
		
	if is_instance_valid(current_right_block):
		current_right_block.show_speech("Opa! Ficou muito pesado!", 2.5)
		
		# Animação de susto / tremor
		var tw_shake = current_right_block.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw_shake.tween_property(current_right_block, "rotation_degrees", -12.0, 0.08)
		tw_shake.tween_property(current_right_block, "rotation_degrees", 12.0, 0.08)
		tw_shake.tween_property(current_right_block, "rotation_degrees", 0.0, 0.08)
		
	await get_tree().create_timer(1.2).timeout
	
	# Desfaz a fusão (Split suave): ejeta o excesso de volta para a mesa e restaura o Bloco 1
	_reset_right_plate_to_one()

## Restaura o prato direito para o Bloco 1 após a sobrecarga
func _reset_right_plate_to_one() -> void:
	if is_instance_valid(current_right_block):
		current_right_block.queue_free()
		
	var block_scene = load("res://Scenes/NumberBlock.tscn")
	current_right_block = block_scene.instantiate() as NumberBlock
	current_right_block.value = 1
	current_right_block.position = Vector2(0, -25)
	right_plate.add_child(current_right_block)
	
	# Também instancia um bloco 1 e 2 na base da tela para a criança tentar de novo
	var parent_scene = get_parent()
	if parent_scene:
		var spawned_block = block_scene.instantiate() as NumberBlock
		spawned_block.value = 2
		spawned_block.position = Vector2(1200, 880)
		parent_scene.add_child(spawned_block)
		
	right_weight = 1
	emit_signal("peso_atualizado", 1)
	_apply_tilt(true)
	is_locked = false

## Inclina o braço da balança conforme a diferença de peso (Interpolação com Tween)
func _apply_tilt(animate: bool) -> void:
	if balance_tween and balance_tween.is_running():
		balance_tween.kill()
		
	var diff: float = float(right_weight - left_weight)
	# Ângulo base proporcional (cada 1 ponto de peso = ~7.5 graus de inclinação)
	var target_deg: float = clampf(diff * 7.5, -24.0, 24.0)
	
	# Se estiver com sobrecarga, inclina com ênfase visual extra (+32 graus)
	if right_weight > left_weight:
		target_deg = minf(32.0, target_deg + 8.0)
	elif right_weight == left_weight:
		target_deg = 0.0 # Perfeitamente horizontal
		
	if not animate:
		if beam:
			beam.rotation_degrees = target_deg
		return
		
	balance_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	balance_tween.tween_property(beam, "rotation_degrees", target_deg, 0.7)

## Efeito de partículas mágicas no prato
func _spawn_sparkle_particles(pos: Vector2) -> void:
	var part = CPUParticles2D.new()
	part.position = pos
	part.emitting = true
	part.amount = 20
	part.lifetime = 0.6
	part.one_shot = true
	part.explosiveness = 0.8
	part.spread = 180.0
	part.initial_velocity_min = 60.0
	part.initial_velocity_max = 140.0
	part.color = Color("#FFD700")
	add_child(part)
	get_tree().create_timer(1.0).timeout.connect(part.queue_free)
