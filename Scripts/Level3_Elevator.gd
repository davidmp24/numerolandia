extends Node2D

@onready var level_manager: LevelManager = $LevelManager
@onready var elevator_area: Area2D = $ElevatorCabin/CabinArea
@onready var cabin: Node2D = $ElevatorCabin
@onready var door: Node2D = $ElevatorCabin/DoorVisual

var is_elevator_activated: bool = false

func _ready() -> void:
	level_manager.level_title = "Mundo 1 - Fase 3: O Elevador Exigente (3 + 2 = 5)"
	level_manager.level_objective = "O elevador só leva o número Cinco! Junte as peças certas para formar o 5!"
	level_manager.next_scene_path = "res://Scenes/Level4_RainbowToll.tscn"
	
	elevator_area.area_entered.connect(_on_elevator_entered)
	
	# Fala inicial do 3
	await get_tree().create_timer(0.6).timeout
	var block_3 = $Block_3
	if block_3:
		block_3.show_speech("O elevador só leva o Cinco! Quantos faltam?", 3.2)

func _on_elevator_entered(area: Area2D) -> void:
	if is_elevator_activated:
		return
		
	if area is NumberBlock:
		var nb = area as NumberBlock
		if nb.value == 5:
			_activate_elevator(nb)
		elif nb.value > 5:
			nb.say_too_big()
		else:
			nb.show_speech("Ainda falta! O elevador precisa do 5!", 2.5)

func _activate_elevator(passenger: NumberBlock) -> void:
	is_elevator_activated = true
	
	# O passageiro centraliza no elevador
	passenger.is_dragging = false
	passenger.global_position = cabin.global_position + Vector2(0, 40)
	
	# Animação de fechar a porta
	var tw_door = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw_door.tween_property(door, "position:x", 0.0, 0.4)
	
	if AudioManager:
		AudioManager.play_split_sound()
		
	await tw_door.finished
	await get_tree().create_timer(0.3).timeout
	
	# O elevador sobe em direção ao topo
	var tw_lift = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw_lift.tween_property(cabin, "position:y", -400.0, 1.4)
	tw_lift.parallel().tween_property(passenger, "position:y", passenger.position.y - 1200.0, 1.4)
	
	await tw_lift.finished
	level_manager.trigger_victory("Sensacional! Três mais dois é igual a Cinco! Elevador a caminho!")
