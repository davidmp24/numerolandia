extends Area2D
class_name FluffyCreature

# Criaturinha Fofa que anda saltitando em busca de bloquinhos
@export var speed: float = 65.0
@export var body_color: Color = Color("#FF9FF3")

var target_block: NumberBlock = null
var is_pacified: bool = false
var hop_time: float = 0.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# Cores doces e variadas para as criaturinhas
	var palette = [Color("#FF9FF3"), Color("#54A0FF"), Color("#5F27CD"), Color("#FFAF40")]
	body_color = palette.pick_random()
	hop_time = randf() * TAU

func _process(delta: float) -> void:
	if is_pacified:
		queue_redraw()
		return
		
	# Verifica se existe o bloco 7 em cena
	var blocks = get_tree().get_nodes_in_group("number_blocks")
	var rainbow_seven_present = false
	for b in blocks:
		if b is NumberBlock and b.value == 7:
			rainbow_seven_present = true
			break
			
	if rainbow_seven_present:
		pacify()
		return
		
	# Procura o bloco solto mais próximo
	_find_nearest_block(blocks)
	
	if target_block != null and is_instance_valid(target_block):
		var dir = (target_block.global_position - global_position).normalized()
		global_position += dir * speed * delta
		
		# Animação de pulinho
		hop_time += delta * 7.0
		position.y += sin(hop_time) * 1.2
	
	queue_redraw()

func _find_nearest_block(blocks: Array) -> void:
	var min_dist = 999999.0
	target_block = null
	for b in blocks:
		if b is NumberBlock and not b.is_destroyed:
			var d = global_position.distance_to(b.global_position)
			if d < min_dist:
				min_dist = d
				target_block = b

func pacify() -> void:
	if is_pacified:
		return
	is_pacified = true
	var tw = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2(1.2, 1.2), 0.3)
	tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)

func _draw() -> void:
	# Corpo fofo e redondo
	draw_circle(Vector2.ZERO, 38.0, body_color)
	draw_circle(Vector2.ZERO, 38.0, body_color.darkened(0.15), false, 4.0)
	
	# Orelhinhas
	draw_circle(Vector2(-24, -28), 12.0, body_color)
	draw_circle(Vector2(24, -28), 12.0, body_color)
	draw_circle(Vector2(-24, -28), 6.0, Color.WHITE)
	draw_circle(Vector2(24, -28), 6.0, Color.WHITE)
	
	if is_pacified:
		# Olhinhos fechados e felizes (arcos sorrindo)
		var pts1 = [Vector2(-22, -6), Vector2(-15, -12), Vector2(-8, -6)]
		var pts2 = [Vector2(8, -6), Vector2(15, -12), Vector2(22, -6)]
		draw_polyline(PackedVector2Array(pts1), Color("#2F3542"), 3.5)
		draw_polyline(PackedVector2Array(pts2), Color("#2F3542"), 3.5)
		
		# Sorrisinho com linguinha
		draw_arc(Vector2(0, 10), 8.0, 0, PI, 10, Color("#2F3542"), 3.5)
		
		# Coraçãozinho flutuante no topo
		_draw_heart(Vector2(0, -48))
	else:
		# Olhos arregalados e curiosos
		draw_circle(Vector2(-14, -8), 10.0, Color.WHITE)
		draw_circle(Vector2(-14, -8), 5.0, Color("#2F3542"))
		draw_circle(Vector2(-12, -10), 2.0, Color.WHITE)
		
		draw_circle(Vector2(14, -8), 10.0, Color.WHITE)
		draw_circle(Vector2(14, -8), 5.0, Color("#2F3542"))
		draw_circle(Vector2(16, -10), 2.0, Color.WHITE)
		
		# Boquinha "o" de curiosidade
		draw_circle(Vector2(0, 12), 4.5, Color("#2F3542"))

func _draw_heart(pos: Vector2) -> void:
	draw_circle(pos + Vector2(-6, -4), 7.0, Color("#FF4757"))
	draw_circle(pos + Vector2(6, -4), 7.0, Color("#FF4757"))
	var pts = PackedVector2Array([
		pos + Vector2(-12, -2),
		pos + Vector2(12, -2),
		pos + Vector2(0, 12)
	])
	draw_polygon(pts, [Color("#FF4757"), Color("#FF4757"), Color("#FF4757")])
