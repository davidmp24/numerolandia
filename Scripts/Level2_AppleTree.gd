extends Node2D

@onready var level_manager: LevelManager = $LevelManager
@onready var apple_area: Area2D = $AppleTree/AppleArea
@onready var apple_sprite: Node2D = $AppleTree/AppleArea/AppleVisual

var is_apple_collected: bool = false

func _ready() -> void:
	level_manager.level_title = "Mundo 1 - Fase 2: A Escada para a Maçã (2 + 1 = 3)"
	level_manager.level_objective = "O Dois não alcança a maçã! Junte blocos 1 para formar o 3 ou 4!"
	level_manager.next_scene_path = "res://Scenes/Level3_Elevator.tscn"
	
	apple_area.area_entered.connect(_on_apple_area_entered)

func _on_apple_area_entered(area: Area2D) -> void:
	if is_apple_collected:
		return
		
	if area is NumberBlock:
		var nb = area as NumberBlock
		if nb.value >= 3:
			_collect_apple(nb)
		else:
			nb.say_too_big() if nb.value > 4 else nb.show_speech("Ainda não alcanço! Preciso ser o 3 ou 4!", 2.5)

func _collect_apple(collector: NumberBlock) -> void:
	is_apple_collected = true
	
	# Animação da maçã sendo colhida e caindo alegremente
	var tw = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tw.tween_property(apple_sprite, "scale", Vector2(1.4, 1.4), 0.15)
	tw.tween_property(apple_sprite, "position:y", 280.0, 0.6)
	
	collector.show_speech("Hummm, que maçã gostosa!", 3.0)
	
	if AudioManager:
		AudioManager.play_click_sound()
		
	await tw.finished
	await get_tree().create_timer(0.6).timeout
	level_manager.trigger_victory("Parabéns! Dois mais um é igual a Três! Você alcançou a maçã!")
