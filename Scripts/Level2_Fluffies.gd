extends Node2D

@onready var level_manager: LevelManager = $LevelManager
@onready var creatures_container: Node2D = $CreaturesContainer

var is_level_won: bool = false
var victory_check_timer: float = 0.0

func _ready() -> void:
	level_manager.level_title = "Fase 2: As Coisinhas Fofas"
	level_manager.level_objective = "Crie o Bloco 7 Arco-Íris para encantar as criaturinhas fofas!"
	level_manager.next_scene_path = "res://Scenes/Playground.tscn"

func _process(delta: float) -> void:
	if is_level_won:
		return
		
	victory_check_timer += delta
	if victory_check_timer >= 0.2:
		victory_check_timer = 0.0
		_check_rainbow_seven_condition()

func _check_rainbow_seven_condition() -> void:
	var blocks = get_tree().get_nodes_in_group("number_blocks")
	for b in blocks:
		if b is NumberBlock and b.value == 7 and not b.is_destroyed:
			_trigger_fluffy_victory()
			break

func _trigger_fluffy_victory() -> void:
	is_level_won = true
	
	# Pacifica todas as criaturinhas
	for c in creatures_container.get_children():
		if c is FluffyCreature:
			c.pacify()
			
	if AudioManager:
		AudioManager.play_number_sound(7)
		
	# Espera um momento de encanto antes de exibir a vitória
	await get_tree().create_timer(1.2).timeout
	level_manager.trigger_victory("O Bloco 7 Arco-Íris protegeu e encantou todas as criaturinhas!")
