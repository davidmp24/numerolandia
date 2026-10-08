extends CanvasLayer
class_name LevelManager

const IconBtn = preload("res://Scripts/IconButton.gd")
const ProgressScript = preload("res://Scripts/Progress.gd")

# HUD sem texto: casa (menu), seta circular (reiniciar) e alto-falante (ouvir a missão de novo).
# A missão é falada em voz alta; ao vencer, aparecem estrelas e um botão grande de avançar.

signal level_completed
signal level_restarted

@export var level_title: String = "Fase"
@export var level_objective: String = "Alcance o objetivo!"
@export var next_scene_path: String = ""

var is_won: bool = false
var victory_panel: Control
var victory_card: Control
var victory_text: String = ""
var _owner_scene_path: String = ""

func _ready() -> void:
	_build_hud()
	_build_victory()
	# Os scripts das fases definem o objetivo depois do _ready deste nó
	await get_tree().create_timer(0.9).timeout
	speak_objective()

func _build_hud() -> void:
	var home = IconBtn.new()
	home.icon_type = "home"
	home.bg_color = Color("#FF6B6B")
	home.position = Vector2(24, 24)
	home.custom_minimum_size = Vector2(130, 130)
	home.pressed.connect(_on_back_button_pressed)
	add_child(home)

	var speaker = IconBtn.new()
	speaker.icon_type = "speaker"
	speaker.bg_color = Color("#54A0FF")
	speaker.position = Vector2(1920 - 24 - 130 * 2 - 20, 24)
	speaker.custom_minimum_size = Vector2(130, 130)
	speaker.pulse = true
	speaker.pressed.connect(speak_objective)
	add_child(speaker)

	var restart = IconBtn.new()
	restart.icon_type = "restart"
	restart.bg_color = Color("#FF9F43")
	restart.position = Vector2(1920 - 24 - 130, 24)
	restart.custom_minimum_size = Vector2(130, 130)
	restart.pressed.connect(_on_restart_button_pressed)
	add_child(restart)

func _build_victory() -> void:
	victory_panel = Control.new()
	victory_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	victory_panel.visible = false
	add_child(victory_panel)

	var dim = ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.5)
	victory_panel.add_child(dim)

	victory_card = Control.new()
	victory_card.position = Vector2(960 - 380, 540 - 280)
	victory_card.size = Vector2(760, 560)
	victory_card.pivot_offset = victory_card.size * 0.5
	victory_card.set_script(load("res://Scripts/VictoryCard.gd"))
	victory_panel.add_child(victory_card)

	var home = IconBtn.new()
	home.icon_type = "home"
	home.bg_color = Color("#FF6B6B")
	home.position = Vector2(110, 340)
	home.custom_minimum_size = Vector2(190, 190)
	home.pressed.connect(_on_back_button_pressed)
	victory_card.add_child(home)

	var next = IconBtn.new()
	next.icon_type = "next"
	next.bg_color = Color("#2ED573")
	next.position = Vector2(460, 340)
	next.custom_minimum_size = Vector2(190, 190)
	next.pulse = true
	next.pressed.connect(_on_next_level_button_pressed)
	victory_card.add_child(next)

func speak_objective() -> void:
	if is_won:
		return
	if AudioManager:
		AudioManager.speak(level_objective)

func trigger_victory(message: String = "Parabéns! Você conseguiu!") -> void:
	if is_won:
		return
	is_won = true
	victory_text = message
	emit_signal("level_completed")

	var scene = get_tree().current_scene
	if scene:
		ProgressScript.mark_done(scene.scene_file_path)

	if AudioManager:
		AudioManager.play_victory_sound()
		AudioManager.speak(message)

	victory_panel.visible = true
	victory_panel.modulate = Color(1, 1, 1, 0)
	victory_card.scale = Vector2(0.5, 0.5)
	var tw = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(victory_panel, "modulate", Color(1, 1, 1, 1), 0.4)
	tw.parallel().tween_property(victory_card, "scale", Vector2.ONE, 0.4)

func _stop_voice() -> void:
	if AudioManager:
		AudioManager.stop_speaking()

func _on_back_button_pressed() -> void:
	_stop_voice()
	if AudioManager:
		AudioManager.play_click_sound()
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _on_restart_button_pressed() -> void:
	_stop_voice()
	if AudioManager:
		AudioManager.play_click_sound()
	emit_signal("level_restarted")
	get_tree().reload_current_scene()

func _on_next_level_button_pressed() -> void:
	_stop_voice()
	if AudioManager:
		AudioManager.play_click_sound()
	if next_scene_path != "" and ResourceLoader.exists(next_scene_path):
		get_tree().change_scene_to_file(next_scene_path)
	else:
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
