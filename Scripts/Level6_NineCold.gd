extends Node2D

@onready var level_manager: LevelManager = $LevelManager
@onready var block_9: NumberBlock = $Block_9
@onready var goal_area: Area2D = $GoalArea

var sneezes_count: int = 0
var is_finished: bool = false

func _ready() -> void:
	level_manager.level_title = "Mundo 2 - Fase 6: O Resfriado do Nove"
	level_manager.level_objective = "O Nove está com frio e quer chegar na casinha! Toque no botão de espirro para diminuir e passar pelos portões!"
	level_manager.next_scene_path = "res://Scenes/Level7_RocketLaunch.tscn"
	
	goal_area.area_entered.connect(_on_goal_entered)
	
	# Conecta clique no Numberling do 9 para espirrar
	if block_9:
		block_9.can_split = false # Desabilita divisão manual por duplo clique/corte (Inconsistência 3.1)
		block_9.numberling_clicked.connect(_on_nine_clicked)
		await get_tree().create_timer(0.6).timeout
		block_9.show_speech("Atchim! Preciso espirrar para passar pelos portões!", 3.2)

func _on_nine_clicked(_val: int) -> void:
	if is_finished or not is_instance_valid(block_9):
		return
		
	if block_9.value > 6:
		block_9.sneeze_drop_one()
		sneezes_count += 1
		
		# Animação suave para frente na trilha
		var tw = block_9.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(block_9, "position:x", block_9.position.x + 280.0, 0.5)

func _on_sneeze_button_pressed() -> void:
	_on_nine_clicked(9)

func _on_goal_entered(area: Area2D) -> void:
	if is_finished:
		return
		
	if area is NumberBlock:
		var nb = area as NumberBlock
		if nb.value <= 6:
			is_finished = true
			nb.show_speech("Cheguei na casinha quentinha com chá quentinho!", 3.0)
			await get_tree().create_timer(1.0).timeout
			level_manager.trigger_victory("Viva! O Nove espirrou, diminuiu e chegou na casinha quentinha!")
