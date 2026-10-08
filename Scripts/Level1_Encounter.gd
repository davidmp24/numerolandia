extends Node2D

@onready var level_manager: LevelManager = $LevelManager
@onready var bridge: Node2D = $Bridge
@onready var pressure_plate: Area2D = $PressurePlate
@onready var spawn_point: Marker2D = $SkySpawnPoint

var first_click_done: bool = false
var is_bridge_down: bool = false
var block_scene = preload("res://Scenes/NumberBlock.tscn")

func _ready() -> void:
	level_manager.level_title = "Mundo 1 - Fase 1: O Encontro (1 + 1)"
	level_manager.level_objective = "Toque no 1 e junte os blocos para formar o 2 e abaixar a ponte!"
	level_manager.next_scene_path = "res://Scenes/Level2_AppleTree.tscn"
	
	pressure_plate.area_entered.connect(_on_pressure_plate_entered)
	
	# Conecta o clique no bloco 1 inicial
	var block_1 = $NumberBlock_Start
	if block_1:
		block_1.numberling_clicked.connect(_on_first_block_clicked)

func _on_first_block_clicked(_val: int) -> void:
	if first_click_done:
		return
	first_click_done = true
	
	# Segundo bloco 1 cai do céu com surpresa e balão de fala
	await get_tree().create_timer(0.4).timeout
	var falling_1 = block_scene.instantiate() as NumberBlock
	falling_1.value = 1
	falling_1.global_position = spawn_point.global_position
	add_child(falling_1)
	
	var tw = falling_1.create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tw.tween_property(falling_1, "global_position", Vector2(580, 680), 0.7)
	
	await tw.finished
	falling_1.show_speech("Junte a gente!", 2.8)

func _on_pressure_plate_entered(area: Area2D) -> void:
	if is_bridge_down:
		return
		
	if area is NumberBlock:
		var nb = area as NumberBlock
		if nb.value >= 2:
			_lower_bridge()
		else:
			nb.show_speech("Preciso de peso 2 para abaixar a ponte!", 2.5)

func _lower_bridge() -> void:
	is_bridge_down = true
	
	# Animação da ponte de madeira descendo sobre o vão
	var tw = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tw.tween_property(bridge, "rotation_degrees", 0.0, 0.8)
	
	if AudioManager:
		AudioManager.play_split_sound()
		
	await tw.finished
	await get_tree().create_timer(0.4).timeout
	level_manager.trigger_victory("Muito bem! Um mais um é igual a Dois, e a ponte abaixou!")
