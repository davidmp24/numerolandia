extends Node2D

@onready var level_manager: LevelManager = $LevelManager
@onready var launch_btn: Button = $CanvasLayerUI/LaunchButton
@onready var countdown_label: Label = $CanvasLayerUI/CountdownLabel

var rocket_block: NumberBlock = null
var is_launching: bool = false
var victory_check_timer: float = 0.0

func _ready() -> void:
	level_manager.level_title = "Mundo 3 - Fase 7: O Lançamento do Foguete (4 + 4 + 2 = 10)"
	level_manager.level_objective = "Junte os módulos (4 + 4 + 2) para montar o Foguete 10 e decolar para o espaço!"
	level_manager.next_scene_path = "res://Scenes/Playground.tscn"
	
	launch_btn.visible = false
	countdown_label.visible = false

func _process(delta: float) -> void:
	if is_launching:
		return
		
	# Observador para validar a integridade do bloco 10 (Inconsistência 3.2)
	if rocket_block != null:
		if not is_instance_valid(rocket_block) or rocket_block.is_destroyed or rocket_block.value != 10:
			rocket_block = null
			launch_btn.hide()
			countdown_label.hide()
		return
		
	victory_check_timer += delta
	if victory_check_timer >= 0.25:
		victory_check_timer = 0.0
		_check_rocket_ten()

func _check_rocket_ten() -> void:
	var blocks = get_tree().get_nodes_in_group("number_blocks")
	for b in blocks:
		if b is NumberBlock and b.value == 10 and not b.is_destroyed:
			rocket_block = b
			_prepare_launch(b)
			break

func _prepare_launch(ten: NumberBlock) -> void:
	# Centraliza o foguete na plataforma de lançamento
	ten.is_dragging = false
	var tw = ten.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(ten, "global_position", Vector2(960, 580), 0.6)
	
	ten.show_speech("Foguete 10 pronto para a missão!", 3.5)
	
	await tw.finished
	if not is_instance_valid(ten) or ten.is_destroyed or ten.value != 10:
		launch_btn.hide()
		return
		
	launch_btn.show()
	var tw_btn = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tw_btn.tween_property(launch_btn, "scale", Vector2(1.15, 1.15), 0.2)
	tw_btn.tween_property(launch_btn, "scale", Vector2(1.0, 1.0), 0.15)

func _on_launch_button_pressed() -> void:
	if is_launching:
		return
	is_launching = true
	launch_btn.visible = false
	countdown_label.visible = true
	
	# Contagem regressiva: 3, 2, 1... DECOLAR!
	var counts = ["3", "2", "1", "!"]
	for i in range(counts.size()):
		countdown_label.text = counts[i]
		if AudioManager:
			AudioManager.play_click_sound()
		await get_tree().create_timer(0.8).timeout
		
	# Decolagem do foguete espacial para o infinito
	if AudioManager:
		AudioManager.play_number_sound(10)
		
	if rocket_block and is_instance_valid(rocket_block):
		var tw_fly = rocket_block.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tw_fly.tween_property(rocket_block, "global_position:y", -400.0, 1.6)
		tw_fly.parallel().tween_property(rocket_block, "scale", Vector2(0.5, 0.5), 1.6)
		await tw_fly.finished
		
	level_manager.trigger_victory("MISSÃO CUMPRIDA! Quatro mais quatro mais dois é igual a Dez! Você completou a jornada de Numerolândia!")
