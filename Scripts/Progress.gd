extends RefCounted

# Progresso salvo localmente (offline) para mostrar estrelinhas nas fases concluídas.
const FILE := "user://progress.cfg"

static func is_done(scene_path: String) -> bool:
	var cfg = ConfigFile.new()
	if cfg.load(FILE) != OK:
		return false
	return cfg.get_value("done", scene_path, false)

static func mark_done(scene_path: String) -> void:
	if scene_path == "":
		return
	var cfg = ConfigFile.new()
	cfg.load(FILE)
	cfg.set_value("done", scene_path, true)
	cfg.save(FILE)
