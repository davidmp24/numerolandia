extends Control

const IconBtn = preload("res://Scripts/IconButton.gd")
const LevelCardScript = preload("res://Scripts/LevelCard.gd")

# Menu 100% visual: botões grandes com figuras, sem depender de leitura.

const LEVELS := [
	"res://Scenes/Level1_Garden.tscn",
	"res://Scenes/Level3_AppleTree.tscn",
	"res://Scenes/Level4_MagicScale.tscn",
	"res://Scenes/Level5_NarrowCave.tscn",
	"res://Scenes/Level6_NineCold.tscn",
	"res://Scenes/Level7_RocketLaunch.tscn",
	"res://Scenes/Level1_Castle.tscn",
	"res://Scenes/Level2_Fluffies.tscn",
]
const WORLD_COLORS := [Color("#2ED573"), Color("#E84393"), Color("#FF9F43"), Color("#A29BFE")]

var main_box: Control
var levels_box: Control

func _ready() -> void:
	_build_main()
	_build_levels()
	_show_main()
	await get_tree().create_timer(0.5).timeout
	if AudioManager:
		AudioManager.speak("Vamos brincar com os números!")

func _build_main() -> void:
	main_box = Control.new()
	main_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(main_box)

	var title = Label.new()
	title.text = "NUMEROLÂNDIA"
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.anchor_left = 0.0
	title.anchor_right = 1.0
	title.offset_top = 40
	title.offset_bottom = 140
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_color", Color.WHITE)
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.4))
	title.add_theme_constant_override("shadow_offset_x", 4)
	title.add_theme_constant_override("shadow_offset_y", 4)
	main_box.add_child(title)

	var row = HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_CENTER)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 120)
	row.anchor_left = 0.5
	row.anchor_right = 0.5
	row.anchor_top = 0.5
	row.anchor_bottom = 0.5
	row.offset_left = -520
	row.offset_right = 520
	row.offset_top = -230
	row.offset_bottom = 290
	main_box.add_child(row)

	var adv = IconBtn.new()
	adv.icon_type = "flag"
	adv.bg_color = Color("#FF9F43")
	adv.pulse = true
	adv.custom_minimum_size = Vector2(450, 450)
	adv.pressed.connect(_on_adventure_pressed)
	row.add_child(adv)

	var play = IconBtn.new()
	play.icon_type = "blocks"
	play.bg_color = Color("#54A0FF")
	play.custom_minimum_size = Vector2(450, 450)
	play.pressed.connect(_on_playground_pressed)
	row.add_child(play)

func _build_levels() -> void:
	levels_box = Control.new()
	levels_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(levels_box)

	var dim = ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.1, 0.25, 0.5, 0.55)
	levels_box.add_child(dim)

	var back = IconBtn.new()
	back.icon_type = "back"
	back.bg_color = Color("#FF6B6B")
	back.position = Vector2(30, 30)
	back.custom_minimum_size = Vector2(150, 150)
	back.pressed.connect(_on_back_pressed)
	levels_box.add_child(back)

	var rows = VBoxContainer.new()
	rows.anchor_left = 0.5
	rows.anchor_right = 0.5
	rows.anchor_top = 0.5
	rows.anchor_bottom = 0.5
	rows.offset_left = -820
	rows.offset_right = 820
	rows.offset_top = -380
	rows.offset_bottom = 380
	rows.alignment = BoxContainer.ALIGNMENT_CENTER
	rows.add_theme_constant_override("separation", 40)
	levels_box.add_child(rows)

	var row1 = HBoxContainer.new()
	row1.alignment = BoxContainer.ALIGNMENT_CENTER
	row1.add_theme_constant_override("separation", 40)
	rows.add_child(row1)
	var row2 = HBoxContainer.new()
	row2.alignment = BoxContainer.ALIGNMENT_CENTER
	row2.add_theme_constant_override("separation", 40)
	rows.add_child(row2)

	for i in range(LEVELS.size()):
		var card = LevelCardScript.new()
		card.level_index = i + 1
		card.scene_path = LEVELS[i]
		card.card_color = WORLD_COLORS[0] if i < 3 else (WORLD_COLORS[1] if i < 6 else (WORLD_COLORS[2] if i < 7 else WORLD_COLORS[3]))
		card.pressed.connect(open_level.bind(LEVELS[i]))
		(row1 if i < 5 else row2).add_child(card)

func _show_main() -> void:
	main_box.visible = true
	levels_box.visible = false

func _on_adventure_pressed() -> void:
	if AudioManager:
		AudioManager.play_click_sound()
		AudioManager.speak("Escolha uma aventura!")
	main_box.visible = false
	levels_box.visible = true

func _on_playground_pressed() -> void:
	if AudioManager:
		AudioManager.play_click_sound()
	get_tree().change_scene_to_file("res://Scenes/Playground.tscn")

func _on_back_pressed() -> void:
	if AudioManager:
		AudioManager.play_click_sound()
	_show_main()

func open_level(path: String) -> void:
	if AudioManager:
		AudioManager.play_click_sound()
	get_tree().change_scene_to_file(path)
