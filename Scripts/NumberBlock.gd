extends Area2D
class_name NumberBlock

# Sinais emitidos pelo bloco
signal value_changed(new_value: int)
signal merged_with(other_block: NumberBlock, resulting_value: int)
signal split_performed()
signal dragged_start()
signal dragged_end()
signal numberling_clicked(value: int)
signal swipe_performed(direction: Vector2)
signal double_tapped()

# Tamanho padrão de cada bloquinho individual (unidade cúbica)
const CUBE_SIZE: float = 46.0
const HITBOX_EXPANSION: float = 1.45 ## Hitbox 45% maior que a textura para acessibilidade infantil

# Propriedade fundamental exportada
@export var value: int = 1:
	set(val):
		value = max(1, val)
		if is_node_ready():
			update_appearance()
			emit_signal("value_changed", value)

# Controle de Drag and Drop
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var original_z_index: int = 0
var is_destroyed: bool = false

# Cooldown e Travas Globais de Engenharia
var is_processing_math: bool = false ## Trava global de 1 a 2s durante operações matemáticas
@export var can_split: bool = true
var can_merge: bool = true

# Detecção de Duplo Toque com Timer Nativo de 0.3s
var double_tap_timer: float = 0.0
const DOUBLE_TAP_TIMEOUT: float = 0.3
var tap_count: int = 0

# Animações de vida e expressão
var eye_blink_timer: float = 0.0
var next_blink_interval: float = 3.0
var is_blinking: bool = false
var look_offset: Vector2 = Vector2.ZERO
var idle_anim_time: float = 0.0

# Balão de fala do personagem
var speech_text: String = ""
var speech_timer: float = 0.0

# Interação com o Numberling (número no topo da cabeça)
var numberling_scale: float = 1.0
var is_numberling_pulsing: bool = true
var pulse_time: float = 0.0
var numberling_local_rect: Rect2 = Rect2()

# Tolerância de Arraste (Deadzone / Threshold)
const DRAG_THRESHOLD: float = 18.0
var is_potential_drag: bool = false
var touch_start_pos: Vector2 = Vector2.ZERO
var swipe_start_pos: Vector2 = Vector2.ZERO
var is_swiping: bool = false

# Efeito Ímã Magnético de Fusão
var magnetic_target: NumberBlock = null
var magnetic_strength: float = 0.0

# Nós internos
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var label: Label = $Label

func _ready() -> void:
	original_z_index = z_index
	add_to_group("number_blocks")
	input_event.connect(_on_input_event)
	next_blink_interval = randf_range(2.0, 5.0)
	idle_anim_time = randf() * TAU
	pulse_time = randf() * TAU
	
	if collision_shape and collision_shape.shape:
		collision_shape.shape = collision_shape.shape.duplicate()
		
	update_appearance()

func _process(delta: float) -> void:
	idle_anim_time += delta
	
	# Timer de Duplo Toque de 0.3s
	if double_tap_timer > 0.0:
		double_tap_timer -= delta
		if double_tap_timer <= 0.0:
			tap_count = 0
	
	# Pulso suave do Numberling no início para convidar o toque da criança
	if is_numberling_pulsing:
		pulse_time += delta * 4.0
		numberling_scale = 1.0 + sin(pulse_time) * 0.12
		queue_redraw()
		
	# Verificação da tolerância de arraste (drag_threshold = 18.0 px)
	if is_potential_drag and not is_dragging and not is_processing_math:
		if get_global_mouse_position().distance_to(touch_start_pos) >= DRAG_THRESHOLD:
			_start_drag()

	# Arraste suave com efeito ímã magnético
	if is_dragging and not is_processing_math:
		var target_pos = get_global_mouse_position() - drag_offset
		global_position = global_position.lerp(target_pos, 25.0 * delta)
		look_offset = (target_pos - global_position).normalized() * 5.0
		
		# Efeito Ímã: atração magnética quando chega perto de outro bloco (< 160px) válido para somar
		var closest: NumberBlock = null
		var min_d: float = 999999.0
		var blocks = get_tree().get_nodes_in_group("number_blocks")
		for b in blocks:
			if b is NumberBlock and b != self and not b.is_destroyed and not b.is_dragging and b.can_merge and not b.is_processing_math:
				if self.value + b.value <= 10:
					var d = global_position.distance_to(b.global_position)
					if d < min_d:
						min_d = d
						closest = b
					
		if closest != null and min_d < 160.0:
			magnetic_target = closest
			magnetic_strength = clampf((160.0 - min_d) / 160.0, 0.0, 1.0)
			# Atração suave em direção ao parceiro de fusão
			if min_d < 85.0:
				global_position = global_position.lerp(closest.global_position, 10.0 * delta)
		else:
			magnetic_target = null
			magnetic_strength = 0.0
			
		queue_redraw()
	else:
		look_offset = Vector2.ZERO
		magnetic_target = null
		magnetic_strength = 0.0
		
	# Piscar os olhos aleatoriamente
	eye_blink_timer += delta
	if not is_blinking and eye_blink_timer >= next_blink_interval:
		is_blinking = true
		queue_redraw()
		get_tree().create_timer(0.12).timeout.connect(func():
			if is_instance_valid(self) and not is_destroyed:
				is_blinking = false
				eye_blink_timer = 0.0
				next_blink_interval = randf_range(2.5, 6.0)
				queue_redraw()
		)
		
	# Temporizador do balão de fala
	if speech_timer > 0.0:
		speech_timer -= delta
		if speech_timer <= 0.0:
			speech_text = ""
			queue_redraw()
			
	if value in [8, 10]:
		queue_redraw()

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and not event.pressed) or (event is InputEventScreenTouch and not event.pressed):
		is_potential_drag = false
		if is_dragging:
			_end_drag()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_destroyed or is_processing_math:
		return
		
	var local_pos = to_local(get_global_mouse_position())
	
	# 1. Detecção de Swipe Horizontal (InputEventScreenDrag / MouseMotion com delta seguro)
	if event is InputEventScreenDrag:
		var delta_x = event.position.x - touch_start_pos.x
		if abs(delta_x) >= 45.0 or abs(event.velocity.x) >= 250.0:
			is_potential_drag = false
			var dir_x = sign(delta_x if delta_x != 0 else event.velocity.x)
			emit_signal("swipe_performed", Vector2(dir_x, 0))
			return
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var delta_x = event.position.x - touch_start_pos.x
		if abs(delta_x) >= 45.0 or abs(event.relative.x) >= 22.0:
			is_potential_drag = false
			var dir_x = sign(delta_x if delta_x != 0 else event.relative.x)
			emit_signal("swipe_performed", Vector2(dir_x, 0))
			return
	
	# 2. Verifica se tocou especificamente no Numberling (número acima da cabeça)
	if numberling_local_rect.has_point(local_pos):
		if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) or (event is InputEventScreenTouch and event.pressed):
			on_numberling_pressed()
			return
			
	# Trata toques e duplo clique com Timer nativo de 0.3s
	var is_press = false
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		is_press = true
	elif event is InputEventScreenTouch and event.pressed:
		is_press = true
		
	if is_press:
		if double_tap_timer > 0.0:
			# Segundo toque detectado dentro da janela de 0.3s!
			double_tap_timer = 0.0
			tap_count = 0
			is_potential_drag = false
			emit_signal("double_tapped")
			if value > 1 and can_split and not is_processing_math:
				split_block()
				return
		else:
			# Primeiro toque: inicia a janela do Timer de 0.3s
			tap_count = 1
			double_tap_timer = DOUBLE_TAP_TIMEOUT
			touch_start_pos = get_global_mouse_position()
			is_potential_drag = true
	else:
		if (event is InputEventMouseButton and not event.pressed) or (event is InputEventScreenTouch and not event.pressed):
			is_potential_drag = false
			if is_dragging:
				_end_drag()

# Ao tocar no número acima da cabeça: Pulo do número + Fala "Sou o [Número]!"
func on_numberling_pressed() -> void:
	is_numberling_pulsing = false
	
	# Animação de pulo elástico do número
	var tw = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "numberling_scale", 1.55, 0.12)
	tw.tween_property(self, "numberling_scale", 1.0, 0.15)
	
	# Fala do personagem com sua afinação característica
	if AudioManager:
		AudioManager.play_character_intro(value)
		
	var intro_text = "Sou o %d!" % value
	if AudioManager and AudioManager.NUMBER_DATA.has(value):
		intro_text = AudioManager.NUMBER_DATA[value].intro
		
	show_speech(intro_text, 2.0)
	emit_signal("numberling_clicked", value)

func _start_drag() -> void:
	if is_dragging or is_destroyed:
		return
	is_potential_drag = false
	is_numberling_pulsing = false
	is_dragging = true
	drag_offset = get_global_mouse_position() - global_position
	z_index = 100
	emit_signal("dragged_start")
	
	var tw = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2(1.12, 1.12), 0.15)
	
	if AudioManager:
		AudioManager.play_click_sound()

func _end_drag() -> void:
	is_potential_drag = false
	if not is_dragging or is_destroyed:
		return
	is_dragging = false
	z_index = original_z_index
	emit_signal("dragged_end")
	
	var tw = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.25)
	
	_check_merge()

func _check_merge() -> void:
	if not can_merge or is_destroyed:
		return
		
	var overlapping = get_overlapping_areas()
	var target_block: NumberBlock = null
	var min_distance = 999999.0
	
	for area in overlapping:
		if area is NumberBlock and area != self and not area.is_destroyed and not area.is_dragging and area.can_merge:
			var d = global_position.distance_to(area.global_position)
			if d < min_distance:
				min_distance = d
				target_block = area
				
	# Snap magnético: se a criança soltou o bloco pertinho (< 135px), atrai e funde com sucesso!
	if target_block == null:
		var blocks = get_tree().get_nodes_in_group("number_blocks")
		for b in blocks:
			if b is NumberBlock and b != self and not b.is_destroyed and not b.is_dragging and b.can_merge:
				var d = global_position.distance_to(b.global_position)
				if d < 135.0 and d < min_distance:
					min_distance = d
					target_block = b
				
	if target_block != null:
		merge_into(target_block)

# Fusão com Narração Pedagógica (ex: "Um mais um é igual a Dois!")
func merge_into(other: NumberBlock) -> void:
	if is_destroyed or other.is_destroyed or not can_merge or not other.can_merge:
		return
		
	var val_a: int = self.value
	var val_b: int = other.value
	var new_value: int = val_a + val_b
	
	# Trava de Overflow Máximo 10 (Inconsistência 2.1)
	if new_value > 10:
		# Recuo elástico usando Tween
		var diff = (self.global_position - other.global_position).normalized()
		if diff == Vector2.ZERO:
			diff = Vector2.LEFT
			
		var tw_self = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw_self.tween_property(self, "global_position", self.global_position + diff * 70.0, 0.3)
		
		var tw_other = other.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw_other.tween_property(other, "global_position", other.global_position - diff * 70.0, 0.3)
		
		self.show_speech("Opa! Só vamos até o Dez!", 2.5)
		if AudioManager:
			AudioManager.play_oops_too_big()
		return
		
	is_destroyed = true
	other.is_destroyed = true
	
	var merge_position = (self.global_position + other.global_position) * 0.5
	var parent_node = get_parent()
	
	var block_scene = load("res://Scenes/NumberBlock.tscn")
	var new_block = block_scene.instantiate() as NumberBlock
	new_block.value = new_value
	new_block.global_position = merge_position
	new_block.scale = Vector2(0.25, 0.25)
	new_block.can_merge = false # Imunidade inicial de fusão em cadeia (Inconsistência 2.2)
	parent_node.add_child(new_block)
	
	# Timer de 0.4s de cooldown de fusão
	new_block.get_tree().create_timer(0.4).timeout.connect(func():
		if is_instance_valid(new_block) and not new_block.is_destroyed:
			new_block.can_merge = true
	)
	
	# Narração pedagógica da operação matemática
	var op_key = "%d + %d = %d" % [mini(val_a, val_b), maxi(val_a, val_b), new_value]
	var speech_msg = ""
	if AudioManager:
		speech_msg = AudioManager.play_operation_narrator(op_key)
		if speech_msg == op_key:
			if AudioManager.NUMBER_DATA.has(new_value):
				speech_msg = AudioManager.NUMBER_DATA[new_value].phrase
			else:
				speech_msg = "%d mais %d é igual a %d!" % [val_a, val_b, new_value]
				
	new_block.show_speech(speech_msg, 3.0)
	
	var tw = new_block.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(new_block, "scale", Vector2(1.3, 1.3), 0.2)
	tw.tween_property(new_block, "scale", Vector2(1.0, 1.0), 0.18)
	
	var particles_scene = load("res://Scenes/MergeParticles.tscn")
	if particles_scene:
		var part = particles_scene.instantiate() as Node2D
		part.global_position = merge_position
		parent_node.add_child(part)
		
	if AudioManager:
		AudioManager.play_merge_sound()
		
	emit_signal("merged_with", other, new_value)
	self.queue_free()
	other.queue_free()

func show_speech(text: String, duration: float = 2.5) -> void:
	speech_text = text
	speech_timer = duration
	queue_redraw()
	if AudioManager:
		AudioManager.speak(text)

# Mensagem pedagógica gentil: "Opa, fiquei muito grande!"
func say_too_big() -> void:
	show_speech("Opa, fiquei muito grande!", 2.8)
	if AudioManager:
		AudioManager.play_oops_too_big()
		
	var tw = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self, "rotation_degrees", -6.0, 0.08)
	tw.tween_property(self, "rotation_degrees", 6.0, 0.08)
	tw.tween_property(self, "rotation_degrees", 0.0, 0.08)

# Espirro do Nove (Resfriado): solta um bloquinho 1 com som Atchim e subtrai
func sneeze_drop_one() -> NumberBlock:
	if value <= 1 or is_destroyed:
		return null
		
	var prev_val = value
	var new_val = value - 1
	
	# Animação de tremor pré-espirro
	var tw_sneeze = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw_sneeze.tween_property(self, "scale", Vector2(1.35, 1.35), 0.15)
	tw_sneeze.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
	
	if AudioManager:
		AudioManager.play_sneeze_sound()
		
	# Cria o bloquinho 1 ejetado
	var block_scene = load("res://Scenes/NumberBlock.tscn")
	var dropped_one = block_scene.instantiate() as NumberBlock
	dropped_one.value = 1
	dropped_one.global_position = global_position + Vector2(75, 30)
	get_parent().add_child(dropped_one)
	
	var tw_drop = dropped_one.create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tw_drop.tween_property(dropped_one, "global_position", global_position + Vector2(120, 50), 0.4)
	
	# Atualiza o próprio valor
	self.value = new_val
	
	var op_key = "%d - 1 = %d" % [prev_val, new_val]
	var speech_msg = "Atchim! %d menos um é igual a %d!" % [prev_val, new_val]
	if AudioManager:
		AudioManager.play_operation_narrator(op_key)
	show_speech(speech_msg, 3.0)
	
	return dropped_one

# Mecânica de Corte (Split / Subtração e Divisão)
func split_block() -> void:
	if is_destroyed or value <= 1 or not can_split:
		return
		
	# Caso 1: Bloco Ímpar (3, 5, 7, 9)
	# Regra pedagógica (Inconsistência 1.1): Ímpares não possuem metades inteiras iguais.
	# Ao sofrer corte/duplo clique, ejeta um bloco 1 e subtrai 1 de si mesmo, tornando-se par!
	if value % 2 != 0:
		var prev_val: int = value
		var new_val: int = value - 1
		
		var tw_split = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw_split.tween_property(self, "scale", Vector2(1.2, 1.2), 0.12)
		tw_split.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)
		
		var parent_node = get_parent()
		var block_scene = load("res://Scenes/NumberBlock.tscn")
		var dropped_one = block_scene.instantiate() as NumberBlock
		dropped_one.value = 1
		dropped_one.global_position = global_position
		dropped_one.can_merge = false
		parent_node.add_child(dropped_one)
		
		# Cooldown de 0.4s de fusão no bloco 1 ejetado
		dropped_one.get_tree().create_timer(0.4).timeout.connect(func():
			if is_instance_valid(dropped_one) and not dropped_one.is_destroyed:
				dropped_one.can_merge = true
		)
		
		var tw_drop = dropped_one.create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tw_drop.tween_property(dropped_one, "global_position", global_position + Vector2(110, 30), 0.35)
		
		self.value = new_val
		self.can_merge = false
		get_tree().create_timer(0.4).timeout.connect(func():
			if is_instance_valid(self) and not is_destroyed:
				self.can_merge = true
		)
		
		if AudioManager:
			AudioManager.play_split_sound()
			
		var speech_msg = "%d soltou um e virou %d!" % [prev_val, new_val]
		show_speech(speech_msg, 2.5)
		emit_signal("split_performed")
		return

	# Caso 2: Bloco Par (2, 4, 6, 8, 10)
	# Divide-se rigorosamente ao meio em dois números iguais!
	is_destroyed = true
	var parent_node = get_parent()
	var block_scene = load("res://Scenes/NumberBlock.tscn")
	var half: int = value / 2
	
	var b1 = block_scene.instantiate() as NumberBlock
	b1.value = half
	b1.global_position = global_position
	b1.can_merge = false
	parent_node.add_child(b1)
	
	var b2 = block_scene.instantiate() as NumberBlock
	b2.value = half
	b2.global_position = global_position
	b2.can_merge = false
	parent_node.add_child(b2)
	
	# Cooldown de 0.4s para prevenir fusão em cadeia imediata (Inconsistência 2.2)
	b1.get_tree().create_timer(0.4).timeout.connect(func():
		if is_instance_valid(b1) and not b1.is_destroyed:
			b1.can_merge = true
	)
	b2.get_tree().create_timer(0.4).timeout.connect(func():
		if is_instance_valid(b2) and not b2.is_destroyed:
			b2.can_merge = true
	)
	
	var tw1 = b1.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw1.tween_property(b1, "global_position", global_position + Vector2(-85, -25), 0.25)
	
	var tw2 = b2.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw2.tween_property(b2, "global_position", global_position + Vector2(85, -25), 0.25)
	
	if AudioManager:
		AudioManager.play_split_sound()
		
	var split_speech = "%d se dividiu em dois %d!" % [value, half]
	b1.show_speech(split_speech, 2.5)
	
	emit_signal("split_performed")
	self.queue_free()

func get_character_layout() -> Dictionary:
	match value:
		1:
			return { "cols": 1, "rows": 1, "cubes": [Vector2(0, 0)] }
		2:
			return { "cols": 1, "rows": 2, "cubes": [Vector2(0, -0.5), Vector2(0, 0.5)] }
		3:
			return { "cols": 1, "rows": 3, "cubes": [Vector2(0, -1), Vector2(0, 0), Vector2(0, 1)] }
		4:
			return {
				"cols": 2, "rows": 2,
				"cubes": [
					Vector2(-0.5, -0.5), Vector2(0.5, -0.5),
					Vector2(-0.5, 0.5), Vector2(0.5, 0.5)
				]
			}
		5:
			return {
				"cols": 1, "rows": 5,
				"cubes": [Vector2(0, -2), Vector2(0, -1), Vector2(0, 0), Vector2(0, 1), Vector2(0, 2)]
			}
		6:
			return {
				"cols": 2, "rows": 3,
				"cubes": [
					Vector2(-0.5, -1), Vector2(0.5, -1),
					Vector2(-0.5, 0), Vector2(0.5, 0),
					Vector2(-0.5, 1), Vector2(0.5, 1)
				]
			}
		7:
			return {
				"cols": 1, "rows": 7,
				"cubes": [
					Vector2(0, -3), Vector2(0, -2), Vector2(0, -1),
					Vector2(0, 0),
					Vector2(0, 1), Vector2(0, 2), Vector2(0, 3)
				]
			}
		8:
			return {
				"cols": 2, "rows": 4,
				"cubes": [
					Vector2(-0.5, -1.5), Vector2(0.5, -1.5),
					Vector2(-0.5, -0.5), Vector2(0.5, -0.5),
					Vector2(-0.5, 0.5), Vector2(0.5, 0.5),
					Vector2(-0.5, 1.5), Vector2(0.5, 1.5)
				]
			}
		9:
			return {
				"cols": 3, "rows": 3,
				"cubes": [
					Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1),
					Vector2(-1, 0),  Vector2(0, 0),  Vector2(1, 0),
					Vector2(-1, 1),  Vector2(0, 1),  Vector2(1, 1)
				]
			}
		10:
			return {
				"cols": 2, "rows": 5,
				"cubes": [
					Vector2(-0.5, -2), Vector2(0.5, -2),
					Vector2(-0.5, -1), Vector2(0.5, -1),
					Vector2(-0.5, 0), Vector2(0.5, 0),
					Vector2(-0.5, 1), Vector2(0.5, 1),
					Vector2(-0.5, 2), Vector2(0.5, 2)
				]
			}
		_:
			var r = int(ceil(float(value) / 2.0))
			var list: Array[Vector2] = []
			var count = 0
			var y_start = -float(r - 1) * 0.5
			for row in range(r):
				for col in range(2):
					if count < value:
						list.append(Vector2(-0.5 if col == 0 else 0.5, y_start + row))
						count += 1
			return { "cols": 2, "rows": r, "cubes": list }

func update_appearance() -> void:
	if not label:
		return
	label.visible = false
	
	var layout = get_character_layout()
	var w = float(layout.cols) * CUBE_SIZE + 16.0
	var h = float(layout.rows) * CUBE_SIZE + 45.0
	
	if collision_shape and collision_shape.shape is RectangleShape2D:
		var rect_shape = collision_shape.shape as RectangleShape2D
		# Hitbox Gigante: 45% maior que a textura do personagem para facilitar o toque de crianças pequenas
		rect_shape.size = Vector2(w * HITBOX_EXPANSION, h * HITBOX_EXPANSION)
		# Ajusta centro da colisão
		collision_shape.position = Vector2(0, -12.0)
		
	queue_redraw()

func _draw() -> void:
	var layout = get_character_layout()
	var cubes: Array = layout.cubes
	var total_w = float(layout.cols) * CUBE_SIZE
	var total_h = float(layout.rows) * CUBE_SIZE
	
	var shadow_rect = Rect2(-total_w * 0.5, -total_h * 0.5 + 12.0, total_w, total_h)
	draw_rect(shadow_rect, Color(0, 0, 0, 0.22 if not is_dragging else 0.35), true, 16.0)
	
	_draw_feet(cubes, total_h * 0.5)
	
	for i in range(cubes.size()):
		var grid_pos: Vector2 = cubes[i]
		var cube_center = grid_pos * CUBE_SIZE
		var cube_rect = Rect2(cube_center - Vector2(CUBE_SIZE * 0.5, CUBE_SIZE * 0.5), Vector2(CUBE_SIZE, CUBE_SIZE))
		var cube_color = _get_cube_color(i, cubes.size())
		
		draw_rect(cube_rect, cube_color, true, 8.0)
		
		var highlight = Rect2(cube_rect.position.x + 4, cube_rect.position.y + 3, cube_rect.size.x - 8, 8)
		draw_rect(highlight, Color(1, 1, 1, 0.3), true, 4.0)
		
		var border_color = cube_color.darkened(0.18) if value != 10 else Color("#FF4136")
		var border_width = 3.5 if value != 10 else 4.5
		draw_rect(cube_rect, border_color, false, border_width, 8.0)
		
	_draw_character_features(cubes, total_w, total_h)
	_draw_numberling(total_h * 0.5)
	
	# Feixe magnético luminoso conectando ao bloco próximo durante o arraste
	if magnetic_target != null and is_instance_valid(magnetic_target) and is_dragging:
		var target_local = to_local(magnetic_target.global_position)
		var beam_col = Color(1.0, 0.9, 0.2, 0.6 * magnetic_strength)
		draw_line(Vector2.ZERO, target_local, beam_col, 5.0)
		draw_circle(target_local, 22.0 * magnetic_strength, Color(1.0, 0.8, 0.2, 0.3))
		var mid_beam = target_local * (0.5 + sin(idle_anim_time * 10.0) * 0.15)
		draw_circle(mid_beam, 7.0, Color.WHITE)
	
	if speech_text != "":
		_draw_speech_bubble(total_h * 0.5)

func _get_cube_color(index: int, total: int) -> Color:
	match value:
		1:
			return Color("#FF3838")
		2:
			return Color("#FF851B")
		3:
			return Color("#FFDC00")
		4:
			return Color("#2ECC40")
		5:
			return Color("#0074D9")
		6:
			return Color("#6C5CE7")
		7:
			var rainbow = [
				Color("#FF3838"), Color("#FF851B"), Color("#FFDC00"),
				Color("#2ECC40"), Color("#0074D9"), Color("#3742FA"), Color("#8854D0")
			]
			return rainbow[index % rainbow.size()]
		8:
			return Color("#D63031") if (index % 2 == 0) else Color("#E84393")
		9:
			var shades = [Color("#A4B0BE"), Color("#747D8C"), Color("#57606F")]
			return shades[index % 3]
		10:
			return Color("#FFFFFF")
		_:
			return Color("#F1C40F")

func _draw_feet(cubes: Array, bottom_y: float) -> void:
	var foot_color = Color("#2F3542")
	if value == 1:
		foot_color = Color("#D63031")
	elif value == 2:
		foot_color = Color("#E67E22")
		
	var foot_spacing = 24.0 if value > 1 else 16.0
	draw_rect(Rect2(-foot_spacing - 10, bottom_y - 2, 20, 10), foot_color, true, 5.0)
	draw_rect(Rect2(foot_spacing - 10, bottom_y - 2, 20, 10), foot_color, true, 5.0)

func _draw_character_features(cubes: Array, total_w: float, total_h: float) -> void:
	var head_cube = cubes[0] * CUBE_SIZE
	if value == 4 or value == 9:
		head_cube = Vector2(0, 0)
	elif value == 8:
		head_cube = Vector2(0, -CUBE_SIZE * 0.8)
	elif value == 10:
		head_cube = Vector2(0, -CUBE_SIZE * 1.0)
		
	match value:
		1:
			_draw_cyclops_eye(head_cube + Vector2(0, -4))
			_draw_smile(head_cube + Vector2(0, 12), 16.0)
		2:
			_draw_two_eyes(head_cube + Vector2(-12, -4), head_cube + Vector2(12, -4))
			_draw_glasses(head_cube + Vector2(0, -4), Color("#8854D0"))
			_draw_smile(head_cube + Vector2(0, 12), 16.0)
		3:
			_draw_crown(head_cube + Vector2(0, -CUBE_SIZE * 0.5))
			_draw_two_eyes(head_cube + Vector2(-12, -4), head_cube + Vector2(12, -4))
			_draw_smile(head_cube + Vector2(0, 12), 16.0)
			draw_circle(cubes[1] * CUBE_SIZE + Vector2(0, -8), 6.0, Color("#FF3838"))
			draw_circle(cubes[1] * CUBE_SIZE + Vector2(0, 8), 6.0, Color("#0074D9"))
			draw_circle(cubes[2] * CUBE_SIZE + Vector2(0, 0), 6.0, Color("#2ECC40"))
		4:
			_draw_two_eyes(head_cube + Vector2(-16, -6), head_cube + Vector2(16, -6))
			draw_line(head_cube + Vector2(-25, -18), head_cube + Vector2(-8, -18), Color("#0074D9"), 4.0)
			draw_line(head_cube + Vector2(8, -18), head_cube + Vector2(25, -18), Color("#0074D9"), 4.0)
			_draw_smile(head_cube + Vector2(0, 14), 22.0)
		5:
			_draw_normal_eye(head_cube + Vector2(-13, -4))
			_draw_star_eye(head_cube + Vector2(13, -4), Color("#0074D9"))
			_draw_smile(head_cube + Vector2(0, 12), 16.0)
			_draw_hand_five(Vector2(total_w * 0.5 + 8, head_cube.y))
		6:
			_draw_two_eyes(head_cube + Vector2(-12, -4), head_cube + Vector2(12, -4))
			_draw_smile(head_cube + Vector2(0, 12), 18.0)
			for p_idx in range(min(6, cubes.size())):
				var cp = cubes[p_idx] * CUBE_SIZE
				draw_circle(cp + Vector2(-CUBE_SIZE * 0.35, 0), 4.5, Color("#FFDC00"))
				draw_circle(cp + Vector2(CUBE_SIZE * 0.35, 0), 4.5, Color("#FF3838"))
		7:
			_draw_rainbow_hair(head_cube + Vector2(0, -CUBE_SIZE * 0.5))
			_draw_two_eyes(head_cube + Vector2(-12, -4), head_cube + Vector2(12, -4))
			_draw_smile(head_cube + Vector2(0, 12), 18.0)
			_draw_sparkle(head_cube + Vector2(CUBE_SIZE * 0.5, -CUBE_SIZE * 0.5), 9.0)
		8:
			_draw_octo_tentacles(total_w * 0.5, total_h * 0.5)
			_draw_hero_mask(head_cube + Vector2(0, -4))
			_draw_smile(head_cube + Vector2(0, 16), 20.0)
		9:
			_draw_two_eyes(head_cube + Vector2(-16, -6), head_cube + Vector2(16, -6))
			_draw_smile(head_cube + Vector2(0, 14), 20.0)
			# Lencinho de resfriado fofo no 9
			draw_circle(head_cube + Vector2(22, 18), 7.0, Color.WHITE)
		10:
			_draw_rocket_boosters(total_w * 0.5, total_h * 0.5)
			_draw_star_eye(head_cube + Vector2(-14, -6), Color("#FF4136"))
			_draw_star_eye(head_cube + Vector2(14, -6), Color("#FF4136"))
			_draw_smile(head_cube + Vector2(0, 14), 22.0)
		_:
			_draw_two_eyes(head_cube + Vector2(-12, -4), head_cube + Vector2(12, -4))
			_draw_smile(head_cube + Vector2(0, 12), 18.0)

func _get_default_font() -> Font:
	if ThemeDB and "fallback_font" in ThemeDB and ThemeDB.fallback_font:
		return ThemeDB.fallback_font
	return ThemeDB.get_fallback_font()

# Numberling Interativo (pula e fala ao toque)
func _draw_numberling(top_y: float) -> void:
	var n_pos = Vector2(0, -top_y - 24.0)
	var base_w = 38.0 * numberling_scale
	var base_h = 38.0 * numberling_scale
	var n_size = Vector2(base_w, base_h)
	var n_rect = Rect2(n_pos - n_size * 0.5, n_size)
	
	# Salva a caixa de toque local para detecção de clique
	numberling_local_rect = n_rect
	
	var nb_color = _get_cube_color(0, 1)
	draw_rect(n_rect, nb_color, true, 8.0)
	draw_rect(n_rect, Color.WHITE, false, 3.0, 8.0)
	
	var font = _get_default_font()
	var font_size = int(22.0 * numberling_scale)
	var text = str(value)
	var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	draw_string(font, n_pos + Vector2(-text_size.x * 0.5, text_size.y * 0.35), text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color.WHITE)

func _draw_speech_bubble(top_y: float) -> void:
	var font = _get_default_font()
	var font_size = 18
	var text_size = font.get_string_size(speech_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	var bubble_w = text_size.x + 36.0
	var bubble_h = 38.0
	var bubble_pos = Vector2(0, -top_y - 68.0)
	var rect = Rect2(bubble_pos - Vector2(bubble_w * 0.5, bubble_h * 0.5), Vector2(bubble_w, bubble_h))
	
	draw_rect(rect, Color.WHITE, true, 12.0)
	draw_rect(rect, Color("#2F3542"), false, 3.0, 12.0)
	
	var tip = [
		bubble_pos + Vector2(-6, bubble_h * 0.5),
		bubble_pos + Vector2(6, bubble_h * 0.5),
		bubble_pos + Vector2(0, bubble_h * 0.5 + 8)
	]
	draw_colored_polygon(PackedVector2Array(tip), Color.WHITE)
	draw_polyline(PackedVector2Array([tip[0], tip[2], tip[1]]), Color("#2F3542"), 2.5)
	
	draw_string(font, bubble_pos + Vector2(-text_size.x * 0.5, text_size.y * 0.35), speech_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color("#2F3542"))

func _draw_cyclops_eye(center: Vector2) -> void:
	if is_blinking:
		draw_line(center - Vector2(14, 0), center + Vector2(14, 0), Color("#2F3542"), 4.0)
		return
	draw_circle(center, 16.0, Color.WHITE)
	draw_circle(center, 16.0, Color("#2F3542"), false, 2.5)
	var pupil_pos = center + look_offset
	draw_circle(pupil_pos, 8.0, Color("#2F3542"))
	draw_circle(pupil_pos + Vector2(3, -3), 3.0, Color.WHITE)

func _draw_two_eyes(p1: Vector2, p2: Vector2) -> void:
	if is_blinking:
		draw_line(p1 - Vector2(10, 0), p1 + Vector2(10, 0), Color("#2F3542"), 3.5)
		draw_line(p2 - Vector2(10, 0), p2 + Vector2(10, 0), Color("#2F3542"), 3.5)
		return
	for p in [p1, p2]:
		_draw_normal_eye(p)

func _draw_normal_eye(p: Vector2) -> void:
	draw_circle(p, 10.5, Color.WHITE)
	draw_circle(p, 10.5, Color("#2F3542"), false, 2.0)
	var pupil_pos = p + look_offset * 0.8
	draw_circle(pupil_pos, 5.0, Color("#2F3542"))
	draw_circle(pupil_pos + Vector2(1.5, -1.5), 2.0, Color.WHITE)

func _draw_star_eye(center: Vector2, col: Color) -> void:
	draw_circle(center, 12.0, Color.WHITE)
	draw_circle(center, 12.0, Color("#2F3542"), false, 2.0)
	_draw_star_shape(center, 8.0, col)

func _draw_star_shape(center: Vector2, radius: float, color: Color) -> void:
	var pts = PackedVector2Array()
	for i in range(10):
		var angle = (float(i) / 10.0) * TAU - PI * 0.5
		var r = radius if (i % 2 == 0) else radius * 0.45
		pts.append(center + Vector2(cos(angle) * r, sin(angle) * r))
	draw_polygon(pts, [color, color, color, color, color, color, color, color, color, color])

func _draw_smile(center: Vector2, width: float) -> void:
	var pts = PackedVector2Array()
	var steps = 10
	for i in range(steps + 1):
		var t = float(i) / float(steps)
		var x = lerp(-width * 0.5, width * 0.5, t)
		var y = sin(t * PI) * 5.5
		pts.append(center + Vector2(x, y))
	draw_polyline(pts, Color("#2F3542"), 3.5)

func _draw_glasses(center: Vector2, frame_color: Color) -> void:
	draw_arc(center + Vector2(-12, 0), 12.0, 0, TAU, 16, frame_color, 3.5)
	draw_arc(center + Vector2(12, 0), 12.0, 0, TAU, 16, frame_color, 3.5)
	draw_line(center + Vector2(-2, 0), center + Vector2(2, 0), frame_color, 3.5)

func _draw_crown(pos: Vector2) -> void:
	var pts = PackedVector2Array([
		pos + Vector2(-18, 0),
		pos + Vector2(-18, -14),
		pos + Vector2(-9, -4),
		pos + Vector2(0, -18),
		pos + Vector2(9, -4),
		pos + Vector2(18, -14),
		pos + Vector2(18, 0)
	])
	draw_polygon(pts, [Color("#FFA801"), Color("#FFD32A"), Color("#FFA801"), Color("#FFD32A"), Color("#FFA801"), Color("#FFD32A"), Color("#FFA801")])

func _draw_hand_five(pos: Vector2) -> void:
	draw_circle(pos, 8.0, Color.WHITE)
	for i in range(5):
		var a = -PI * 0.4 + (float(i) * 0.2)
		draw_circle(pos + Vector2(cos(a) * 11.0, sin(a) * 11.0), 3.0, Color.WHITE)

func _draw_hero_mask(center: Vector2) -> void:
	var mask_pts = PackedVector2Array([
		center + Vector2(-28, -8),
		center + Vector2(28, -8),
		center + Vector2(24, 8),
		center + Vector2(0, 4),
		center + Vector2(-24, 8)
	])
	draw_colored_polygon(mask_pts, Color("#2F3542"))
	draw_circle(center + Vector2(-13, 0), 6.0, Color.WHITE)
	draw_circle(center + Vector2(13, 0), 6.0, Color.WHITE)
	draw_circle(center + Vector2(-13, 0), 3.5, Color("#2F3542"))
	draw_circle(center + Vector2(13, 0), 3.5, Color("#2F3542"))

func _draw_octo_tentacles(half_w: float, half_h: float) -> void:
	var wave = sin(idle_anim_time * 6.0) * 6.0
	for i in range(4):
		var y = -half_h + 30.0 + (float(i) * 36.0)
		var left_tip = Vector2(-half_w - 20.0 + wave, y + (i % 2) * 4.0)
		var right_tip = Vector2(half_w + 20.0 - wave, y + (i % 2) * 4.0)
		draw_line(Vector2(-half_w, y), left_tip, Color("#E84393"), 7.0)
		draw_line(Vector2(half_w, y), right_tip, Color("#E84393"), 7.0)
		draw_circle(left_tip, 5.0, Color("#FFA502"))
		draw_circle(right_tip, 5.0, Color("#FFA502"))

func _draw_rocket_boosters(half_w: float, half_h: float) -> void:
	var fin_left = PackedVector2Array([
		Vector2(-half_w, -10),
		Vector2(-half_w - 24, half_h - 10),
		Vector2(-half_w, half_h - 10)
	])
	draw_polygon(fin_left, [Color("#FF4136"), Color("#FF4136"), Color("#FF4136")])
	
	var fin_right = PackedVector2Array([
		Vector2(half_w, -10),
		Vector2(half_w + 24, half_h - 10),
		Vector2(half_w, half_h - 10)
	])
	draw_polygon(fin_right, [Color("#FF4136"), Color("#FF4136"), Color("#FF4136")])
	
	var flame_flicker = sin(idle_anim_time * 25.0) * 8.0
	var flame_pts = PackedVector2Array([
		Vector2(-20, half_h),
		Vector2(0, half_h + 26.0 + flame_flicker),
		Vector2(20, half_h)
	])
	draw_polygon(flame_pts, [Color("#FF851B"), Color("#FFDC00"), Color("#FF851B")])

func _draw_rainbow_hair(pos: Vector2) -> void:
	var r_colors = [Color("#FF3838"), Color("#FF851B"), Color("#FFDC00"), Color("#2ECC40"), Color("#0074D9"), Color("#8854D0")]
	for i in range(r_colors.size()):
		var arc_pos = pos + Vector2(-15.0 + (float(i) * 6.0), -6)
		draw_circle(arc_pos, 5.0, r_colors[i])

func _draw_sparkle(center: Vector2, size: float) -> void:
	draw_line(center - Vector2(size, 0), center + Vector2(size, 0), Color.WHITE, 2.5)
	draw_line(center - Vector2(0, size), center + Vector2(0, size), Color.WHITE, 2.5)
