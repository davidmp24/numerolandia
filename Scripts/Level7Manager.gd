extends Node2D
class_name Level7Manager

## Level7Manager: Controlador da "Fase 7: O Foguete Pesado" (Subtração Regressiva 10 -> 8 -> 4)
## Foco Pedagógico: Subtração Regressiva Concreta e Decolagem Espacial para Crianças de 4 anos

# Referências a nós da cena
@onready var level_manager: LevelManager = $LevelManager
@export var next_scene_path: String = "res://Scenes/Level8_NarrowCave.tscn"

# Plataforma de lançamento e propulsores do foguete
@onready var launch_pad: Node2D = $LaunchPad
@onready var rocket_spawn_point: Marker2D = $LaunchPad/RocketSpawnPoint

# Referência ao Bloco Foguete
var rocket_block: NumberBlock = null
var current_rocket_value: int = 10
var is_processing_math: bool = false
var is_launching: bool = false
var shake_tween: Tween = null

func _ready() -> void:
	# Configuração do HUD e Narrador da Missão
	if level_manager:
		level_manager.level_title = "Fase 7: O Foguete Pesado (10 - 2 = 8 | 8 - 4 = 4)"
		level_manager.level_objective = "O foguete está muito pesado para decolar! Passe o dedinho para cortar o peso excessivo!"
		level_manager.next_scene_path = next_scene_path
		
	_setup_rocket_block(10)
	_start_heavy_rocket_shiver()
	
	# Narração inicial após 0.8s
	await get_tree().create_timer(0.8).timeout
	if AudioManager:
		AudioManager.speak("Estamos muito pesados! Passe o dedinho na horizontal para cortar o peso!")

## Inicializa o bloco do foguete na plataforma
func _setup_rocket_block(val: int) -> void:
	var block_scene = preload("res://Scenes/NumberBlock.tscn")
	var spawn_pos = rocket_spawn_point.global_position if rocket_spawn_point else Vector2(960, 680)
	
	if is_instance_valid(rocket_block):
		rocket_block.queue_free()
		
	rocket_block = block_scene.instantiate() as NumberBlock
	rocket_block.value = val
	rocket_block.global_position = spawn_pos
	rocket_block.can_split = false
	rocket_block.input_pickable = true
	add_child(rocket_block)
	
	current_rocket_value = val
	
	# Conecta o sinal nativo de Swipe do NumberBlock
	rocket_block.swipe_performed.connect(_on_rocket_swiped)

## Animação de tremor do foguete tentando subir, mas travado pelo peso
func _start_heavy_rocket_shiver() -> void:
	if not is_instance_valid(rocket_block) or is_launching:
		return
		
	if shake_tween and shake_tween.is_running():
		shake_tween.kill()
		
	var orig_y = rocket_spawn_point.global_position.y if rocket_spawn_point else 680.0
	shake_tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	shake_tween.tween_property(rocket_block, "position:y", orig_y - 12.0, 0.1)
	shake_tween.tween_property(rocket_block, "position:y", orig_y + 4.0, 0.1)
	shake_tween.tween_property(rocket_block, "position:x", rocket_block.position.x - 3.0, 0.06)
	shake_tween.tween_property(rocket_block, "position:x", rocket_block.position.x + 3.0, 0.06)

## Evento disparado quando a criança realiza um gesto de Swipe horizontal sobre o foguete
func _on_rocket_swiped(_direction: Vector2) -> void:
	if is_processing_math or is_launching or not is_instance_valid(rocket_block):
		return
		
	# Trava de Cooldown Global: Congela novos inputs durante o processamento da operação matemática
	is_processing_math = true
	
	if current_rocket_value == 10:
		_process_first_cut_ten_to_eight()
	elif current_rocket_value == 8:
		_process_second_cut_eight_to_four()

## 1º Corte: Dez ejeta o Dois e se transforma em Oito (10 - 2 = 8)
func _process_first_cut_ten_to_eight() -> void:
	if shake_tween and shake_tween.is_running():
		shake_tween.kill()
		
	var current_pos = rocket_block.global_position
	
	# Instancia o bloco 2 ejetado com impulso lateral e queda suave fora da plataforma
	_spawn_ejected_block_with_physics(2, current_pos, Vector2(280.0, -320.0))
	
	# Atualiza o foguete para o Bloco 8
	_setup_rocket_block(8)
	
	# Efeito de corte sonoro e fala pedagógica
	if AudioManager:
		AudioManager.play_split_sound()
		AudioManager.speak("Dez tira Dois, vira Oito!")
		
	rocket_block.show_speech("Dez tira Dois, vira Oito! Mas ainda estou pesado!", 3.0)
	
	# Animação de alívio e retomada do tremor
	var tw = rocket_block.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(rocket_block, "scale", Vector2(1.2, 1.2), 0.15)
	tw.tween_property(rocket_block, "scale", Vector2(1.0, 1.0), 0.15)
	
	await get_tree().create_timer(1.6).timeout
	_start_heavy_rocket_shiver()
	is_processing_math = false

## 2º Corte & Condição de Vitória: Oito ejeta o Quatro e decola (8 - 4 = 4)
func _process_second_cut_eight_to_four() -> void:
	is_launching = true
	if shake_tween and shake_tween.is_running():
		shake_tween.kill()
		
	var current_pos = rocket_block.global_position
	
	# Instancia o bloco 4 ejetado caindo do outro lado
	_spawn_ejected_block_with_physics(4, current_pos, Vector2(-280.0, -320.0))
	
	# Atualiza o foguete para o Bloco 4 (Quadrado Espacial)
	_setup_rocket_block(4)
	
	if AudioManager:
		AudioManager.play_split_sound()
		AudioManager.speak("Quatro! Decolar!")
		
	rocket_block.show_speech("Quatro! Agora eu posso voar!", 3.0)
	
	await get_tree().create_timer(0.6).timeout
	
	# Animação da Decolagem Triunfante para o Espaço
	_animate_rocket_launch()

## Instancia um bloco ejetado com RigidBody2D temporário e impulso suave
func _spawn_ejected_block_with_physics(ejected_val: int, start_pos: Vector2, impulse_force: Vector2) -> void:
	var rigid = RigidBody2D.new()
	rigid.global_position = start_pos + Vector2(sign(impulse_force.x) * 40.0, -20.0)
	rigid.gravity_scale = 1.6
	rigid.linear_damp = 0.5
	
	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 24.0
	col.shape = shape
	rigid.add_child(col)
	
	var block_scene = preload("res://Scenes/NumberBlock.tscn")
	var ejected_block = block_scene.instantiate() as NumberBlock
	ejected_block.value = ejected_val
	ejected_block.can_split = false
	ejected_block.input_pickable = false
	rigid.add_child(ejected_block)
	
	add_child(rigid)
	
	# Aplica impulso físico para o bloco saltar para o lado e cair
	rigid.apply_impulse(impulse_force)
	
	# Remove suavemente após 3 segundos
	get_tree().create_timer(3.0).timeout.connect(rigid.queue_free)

## Animação de Decolagem do Foguete Bloco 4
func _animate_rocket_launch() -> void:
	if not is_instance_valid(rocket_block):
		return
		
	# Efeito de propulsão sonora e partículas de fogo
	_spawn_rocket_fire_particles(rocket_block.global_position)
	if AudioManager:
		AudioManager.play_number_sound(10)
		
	var tw_launch = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw_launch.tween_property(rocket_block, "position:y", -350.0, 2.0)
	tw_launch.parallel().tween_property(rocket_block, "scale", Vector2(1.35, 1.35), 1.0)
	
	await tw_launch.finished
	await get_tree().create_timer(0.5).timeout
	
	# Dispara vitória e liberação da próxima fase
	if level_manager:
		level_manager.trigger_victory("Parabéns! Dez tira dois é Oito, e Oito tira quatro é Quatro! Decolagem com sucesso!")

## Efeito de partículas de fogo e fumaça da decolagem
func _spawn_rocket_fire_particles(pos: Vector2) -> void:
	var part = CPUParticles2D.new()
	part.position = pos + Vector2(0, 40)
	part.emitting = true
	part.amount = 50
	part.lifetime = 1.2
	part.explosiveness = 0.2
	part.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	part.emission_rect_extents = Vector2(30, 5)
	part.direction = Vector2(0, 1)
	part.spread = 20.0
	part.gravity = Vector2(0, 300)
	part.initial_velocity_min = 150.0
	part.initial_velocity_max = 300.0
	part.scale_amount_min = 8.0
	part.scale_amount_max = 18.0
	
	var grad = Gradient.new()
	grad.set_color(0, Color("#FF4757"))
	grad.add_point(0.4, Color("#FFA502"))
	grad.add_point(0.8, Color("#FFFA65"))
	grad.add_point(1.0, Color(1, 1, 1, 0))
	part.color_ramp = grad
	
	add_child(part)
	get_tree().create_timer(2.5).timeout.connect(part.queue_free)
