extends Node2D

const IconBtn = preload("res://Scripts/IconButton.gd")

# Modo livre sem texto: a criança toca num cubo com bolinhas (1 a 10) para criar o personagem.

const CUBE_COLORS := [
	Color("#FF3838"), Color("#FF851B"), Color("#FFDC00"), Color("#2ECC40"), Color("#0074D9"),
	Color("#6C5CE7"), Color("#8854D0"), Color("#E84393"), Color("#747D8C"), Color("#FFFFFF"),
]

@onready var blocks_container: Node2D = $BlocksContainer
@onready var ui: CanvasLayer = $CanvasLayer

var number_block_scene = preload("res://Scenes/NumberBlock.tscn")

func _ready() -> void:
	_build_ui()
	spawn_block(1, Vector2(500, 500))
	spawn_block(2, Vector2(700, 500))
	spawn_block(3, Vector2(900, 500))

func _build_ui() -> void:
	var home = IconBtn.new()
	home.icon_type = "home"
	home.bg_color = Color("#FF6B6B")
	home.position = Vector2(24, 24)
	home.custom_minimum_size = Vector2(130, 130)
	home.pressed.connect(_on_menu_pressed)
	ui.add_child(home)

	var clear = IconBtn.new()
	clear.icon_type = "clear"
	clear.bg_color = Color("#A55EEA")
	clear.position = Vector2(1920 - 24 - 130, 24)
	clear.custom_minimum_size = Vector2(130, 130)
	clear.pressed.connect(_on_clear_all_pressed)
	ui.add_child(clear)

	var scissors = IconBtn.new()
	scissors.icon_type = "scissors"
	scissors.bg_color = Color("#FF4757")
	scissors.position = Vector2(1920 - 24 - 130 * 2 - 20, 24)
	scissors.custom_minimum_size = Vector2(130, 130)
	scissors.pulse = true
	scissors.pressed.connect(_on_scissors_pressed)
	ui.add_child(scissors)

	var dock = HBoxContainer.new()
	dock.anchor_left = 0.5
	dock.anchor_right = 0.5
	dock.anchor_top = 1.0
	dock.anchor_bottom = 1.0
	dock.offset_left = -900
	dock.offset_right = 900
	dock.offset_top = -170
	dock.offset_bottom = -20
	dock.alignment = BoxContainer.ALIGNMENT_CENTER
	dock.add_theme_constant_override("separation", 14)
	ui.add_child(dock)

	for n in range(1, 11):
		var b = IconBtn.new()
		b.icon_type = "cube"
		b.dots = n
		b.bg_color = CUBE_COLORS[n - 1]
		b.dot_color = Color("#2F3542") if n == 10 else Color.WHITE
		b.custom_minimum_size = Vector2(150, 150)
		b.pressed.connect(_on_spawn_button_pressed.bind(n))
		dock.add_child(b)

func spawn_block(val: int, pos: Vector2 = Vector2.ZERO) -> void:
	if pos == Vector2.ZERO:
		pos = Vector2(randf_range(350, 1550), randf_range(380, 600))

	var block = number_block_scene.instantiate() as NumberBlock
	block.value = val
	block.global_position = pos
	blocks_container.add_child(block)

	block.scale = Vector2(0.2, 0.2)
	var tw = block.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(block, "scale", Vector2(1.0, 1.0), 0.25)

	if AudioManager:
		AudioManager.play_number_sound(val)

func _on_spawn_button_pressed(val: int) -> void:
	if AudioManager:
		AudioManager.play_click_sound()
	spawn_block(val)

func _on_clear_all_pressed() -> void:
	if AudioManager:
		AudioManager.play_split_sound()
	for child in blocks_container.get_children():
		if child is NumberBlock:
			child.queue_free()

func _on_scissors_pressed() -> void:
	# Separa o maior bloco presente na tela
	var candidate: NumberBlock = null
	var max_val = 1
	for child in blocks_container.get_children():
		if child is NumberBlock and not child.is_destroyed and child.value > max_val:
			max_val = child.value
			candidate = child
	if candidate != null:
		candidate.split_block()

func _on_menu_pressed() -> void:
	if AudioManager:
		AudioManager.stop_speaking()
		AudioManager.play_click_sound()
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
