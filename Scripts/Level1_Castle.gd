extends Node2D

@onready var level_manager: LevelManager = $LevelManager
@onready var gate: Node2D = $CastleEnvironment/Gate
@onready var lever: Area2D = $CastleEnvironment/LeverArea
@onready var lever_handle: Node2D = $CastleEnvironment/LeverArea/LeverHandle

var is_gate_opened: bool = false

func _ready() -> void:
	level_manager.level_title = "Fase 1: O Castelo dos Portões"
	level_manager.level_objective = "Crie um bloco de valor 5 ou mais para alcançar e puxar a alavanca!"
	level_manager.next_scene_path = "res://Scenes/Level2_Fluffies.tscn"
	
	lever.area_entered.connect(_on_lever_area_entered)

func _on_lever_area_entered(area: Area2D) -> void:
	if is_gate_opened:
		return
		
	if area is NumberBlock:
		var block = area as NumberBlock
		# Verifica o requisito: value >= 5
		if block.value >= 5:
			_open_castle_gate()
		else:
			# Dica visual se o bloco for muito pequeno
			_animate_lever_shake()

func _open_castle_gate() -> void:
	is_gate_opened = true
	
	# Animação da alavanca puxando para baixo
	var tw_lever = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tw_lever.tween_property(lever_handle, "rotation_degrees", 45.0, 0.35)
	
	if AudioManager:
		AudioManager.play_split_sound()
		
	# Animação do portão do castelo subindo
	var tw_gate = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw_gate.tween_property(gate, "position:y", gate.position.y - 280.0, 1.2)
	
	await tw_gate.finished
	
	# Gatilho de vitória
	level_manager.trigger_victory("O Portão do Castelo se abriu! Você é incrível!")

func _animate_lever_shake() -> void:
	var tw = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(lever_handle, "rotation_degrees", -8.0, 0.08)
	tw.tween_property(lever_handle, "rotation_degrees", 8.0, 0.08)
	tw.tween_property(lever_handle, "rotation_degrees", 0.0, 0.08)
