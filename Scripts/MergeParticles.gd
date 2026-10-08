extends CPUParticles2D

func _ready() -> void:
	emitting = true
	# Autodestrói quando o efeito terminar
	get_tree().create_timer(lifetime + 0.2).timeout.connect(queue_free)
