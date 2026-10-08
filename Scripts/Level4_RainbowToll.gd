extends Node2D

@onready var level_manager: LevelManager = $LevelManager
@onready var cloud_area: Area2D = $SadCloud/CloudArea
@onready var cloud_node: Node2D = $SadCloud

var is_cloud_cleared: bool = false

func _ready() -> void:
	level_manager.level_title = "Mundo 2 - Fase 4: O Pedágio do Arco-Íris (4 + 3 = 7)"
	level_manager.level_objective = "Uma nuvem cinza bloqueia o caminho! Junte o 4 e o 3 para formar o Sete Arco-Íris!"
	level_manager.next_scene_path = "res://Scenes/Level5_NarrowCave.tscn"
	
	cloud_area.area_entered.connect(_on_cloud_entered)

func _on_cloud_entered(area: Area2D) -> void:
	if is_cloud_cleared:
		return
		
	if area is NumberBlock:
		var nb = area as NumberBlock
		if nb.value == 7:
			_clear_cloud_with_rainbow(nb)
		else:
			nb.show_speech("A nuvem precisa das 7 cores do arco-íris!", 2.8)

func _clear_cloud_with_rainbow(rainbow_block: NumberBlock) -> void:
	is_cloud_cleared = true
	
	rainbow_block.show_speech("Sete! O arco-íris traz alegria!", 3.0)
	
	# Transforma a nuvem cinza em colorida e faz subir
	var cloud_visual = cloud_node.get_node("SadCloudVisual")
	if cloud_visual and cloud_visual.has_method("turn_happy"):
		cloud_visual.turn_happy()
		
	var tw = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_property(cloud_node, "position:y", -300.0, 1.5)
	
	if AudioManager:
		AudioManager.play_number_sound(7)
		
	await tw.finished
	level_manager.trigger_victory("Maravilha! Quatro mais três é igual a Sete! O arco-íris iluminou o caminho!")
