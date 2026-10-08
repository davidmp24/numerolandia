extends Node2D

@onready var level_manager: LevelManager = $LevelManager
@onready var tunnel_entrance: Area2D = $CaveVisual/TunnelEntrance
@onready var tunnel_exit: Area2D = $CaveVisual/TunnelExit

var is_cave_cleared: bool = false

func _ready() -> void:
	level_manager.level_title = "Mundo 2 - Fase 5: A Caverna Estreita"
	level_manager.level_objective = "O grandão 8 não cabe no túnel baixinho! Dê dois toques nele para se dividir e passe com o 4!"
	level_manager.next_scene_path = "res://Scenes/Level6_NineCold.tscn"
	
	tunnel_entrance.area_entered.connect(_on_tunnel_entrance_entered)
	tunnel_exit.area_entered.connect(_on_tunnel_exit_entered)
	
	# Fala inicial do Superócto
	await get_tree().create_timer(0.6).timeout
	var block_8 = $Block_8
	if block_8:
		block_8.show_speech("A caverna é baixinha! Olhe a portinha verde do 4!", 3.2)

func _on_tunnel_entrance_entered(area: Area2D) -> void:
	if is_cave_cleared:
		return
		
	if area is NumberBlock:
		var nb = area as NumberBlock
		if nb.value > 4:
			nb.show_speech("Sou muito grandão! Me divida para eu passar!", 2.8)
			nb.say_too_big()

func _on_tunnel_exit_entered(area: Area2D) -> void:
	if is_cave_cleared:
		return
		
	if area is NumberBlock:
		var nb = area as NumberBlock
		if nb.value <= 4:
			is_cave_cleared = true
			nb.show_speech("Consegui passar pelo túnel!", 2.5)
			await get_tree().create_timer(0.8).timeout
			level_manager.trigger_victory("Sensacional! 8 se dividiu em dois 4! O quatro passou pelo túnel!")

func _on_scissors_button_pressed() -> void:
	if is_cave_cleared:
		return
	var blocks = get_tree().get_nodes_in_group("number_blocks")
	for b in blocks:
		if b is NumberBlock and b.value > 1 and not b.is_destroyed:
			b.split_block()
			break
