extends Node2D
class_name Level4Manager

## Level4Manager: Controlador da "Fase 4: A Balança Mágica" (Conceito de Igualdade 4 = 4)
## Foco Pedagógico: Noção Concreta de Igualdade, Pesos e Equivalência para Crianças de 4 anos

# Referências a nós da cena
@onready var level_manager: LevelManager = $LevelManager
@onready var magic_scale: MagicScale = $MagicScale
@onready var magical_gate: Node2D = $MagicalGate
@onready var gate_door_left: Node2D = $MagicalGate/DoorLeft
@onready var gate_door_right: Node2D = $MagicalGate/DoorRight
@onready var gate_lock: Node2D = $MagicalGate/Lock

@export var next_scene_path: String = "res://Scenes/Level5_Seesaw.tscn"

# Controle de Estado e Blocos Soltos
var is_gate_opened: bool = false
var loose_block_scene = preload("res://Scenes/NumberBlock.tscn")

func _ready() -> void:
	# Configuração de Metadados e Objetivos do HUD
	if level_manager:
		level_manager.level_title = "Fase 4: A Balança Mágica (4 = 4)"
		level_manager.level_objective = "O prato do Quatro é pesado! Coloque blocos no outro prato até igualar em Quatro!"
		level_manager.next_scene_path = next_scene_path
		
	# Conexão dos sinais da Balança Mágica
	_setup_scale_connections()
	
	# Instancia blocos extras soltos na base da tela (1, 2 e 3)
	_spawn_loose_blocks()
	
	# Narração introdutória acolhedora após 0.8s
	await get_tree().create_timer(0.8).timeout
	if AudioManager:
		AudioManager.speak("O Bloco Quatro inclinou a balança! Arraste blocos para o outro prato até ficarem com o mesmo peso!")

## Conecta os sinais da balança com os métodos do Level4Manager
func _setup_scale_connections() -> void:
	if not magic_scale:
		return
		
	magic_scale.balanca_nivelada.connect(_on_scale_balanced)
	magic_scale.peso_atualizado.connect(_on_scale_weight_updated)
	magic_scale.sobrecarga.connect(_on_scale_overweight)

## Instancia blocos disponíveis na base da tela para a criança interagir
func _spawn_loose_blocks() -> void:
	var spawn_configs = [
		{ "val": 1, "pos": Vector2(380, 880) },
		{ "val": 2, "pos": Vector2(580, 880) },
		{ "val": 3, "pos": Vector2(1380, 880) },
		{ "val": 2, "pos": Vector2(1580, 880) }
	]
	
	for cfg in spawn_configs:
		var b = loose_block_scene.instantiate() as NumberBlock
		b.value = cfg.val
		b.position = cfg.pos
		add_child(b)

## Evento quando o peso do prato direito é alterado
func _on_scale_weight_updated(new_weight: int) -> void:
	# Feedback visual sutil de partículas
	if magical_gate and new_weight < 4:
		var tw = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_property(gate_lock, "rotation_degrees", -6.0, 0.1)
		tw.tween_property(gate_lock, "rotation_degrees", 6.0, 0.1)
		tw.tween_property(gate_lock, "rotation_degrees", 0.0, 0.1)

## Evento de Sobrecarga (Peso > 4): Tratamento sem punição
func _on_scale_overweight(excess_weight: int) -> void:
	# Dica amigável com balão ou tremor de alívio
	var tw = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self, "position:x", position.x - 4.0, 0.05)
	tw.tween_property(self, "position:x", position.x + 4.0, 0.05)
	tw.tween_property(self, "position:x", position.x, 0.05)

## Condição de Vitória: Balança perfeitamente nivelada (4 = 4)
func _on_scale_balanced() -> void:
	if is_gate_opened:
		return
	is_gate_opened = true
	
	# 1. Narrador comemora a igualdade: "Quatro é igual a Quatro!"
	if AudioManager:
		AudioManager.speak("Quatro é igual a Quatro! A balança está perfeita!")
		AudioManager.play_victory_sound()
		
	await get_tree().create_timer(0.6).timeout
	
	# 2. Abertura triunfante do Portão Mágico
	_animate_open_magical_gate()

## Animação de destrancamento e abertura do portão mágico
func _animate_open_magical_gate() -> void:
	if not is_instance_valid(magical_gate):
		_finish_level()
		return
		
	# Destranca o cadeado com rotação e sumiço luminoso
	if is_instance_valid(gate_lock):
		var tw_lock = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tw_lock.tween_property(gate_lock, "scale", Vector2(1.4, 1.4), 0.15)
		tw_lock.tween_property(gate_lock, "scale", Vector2(0.0, 0.0), 0.25)
		tw_lock.parallel().tween_property(gate_lock, "modulate:a", 0.0, 0.25)
		
	_spawn_gate_magic_sparkles(gate_lock.global_position if is_instance_valid(gate_lock) else Vector2(960, 380))
	
	await get_tree().create_timer(0.3).timeout
	
	# Abre as duas folhas do portão para os lados
	var tw_gate = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if is_instance_valid(gate_door_left):
		tw_gate.parallel().tween_property(gate_door_left, "position:x", gate_door_left.position.x - 160.0, 0.9)
	if is_instance_valid(gate_door_right):
		tw_gate.parallel().tween_property(gate_door_right, "position:x", gate_door_right.position.x + 160.0, 0.9)
		
	await tw_gate.finished
	await get_tree().create_timer(0.5).timeout
	
	_finish_level()

## Aciona a tela de vitória através do LevelManager
func _finish_level() -> void:
	if level_manager:
		level_manager.trigger_victory("Parabéns! Quatro é igual a Quatro, e o Portão Mágico se abriu!")

## Efeito de partículas estelares no portão
func _spawn_gate_magic_sparkles(pos: Vector2) -> void:
	var part = CPUParticles2D.new()
	part.position = pos
	part.emitting = true
	part.amount = 35
	part.lifetime = 1.0
	part.one_shot = true
	part.explosiveness = 0.9
	part.spread = 180.0
	part.initial_velocity_min = 100.0
	part.initial_velocity_max = 220.0
	part.scale_amount_min = 6.0
	part.scale_amount_max = 12.0
	part.color = Color("#70A1FF")
	add_child(part)
	get_tree().create_timer(1.5).timeout.connect(part.queue_free)
