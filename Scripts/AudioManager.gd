extends Node

# AudioManager: Sistema de Narrador, Vozes Individuais e Sons Reativos para Numerolândia
# Suporta carregamento de arquivos .ogg/.wav pré-gravados e síntese procedural com afinações específicas

var audio_players: Array[AudioStreamPlayer] = []
const POOL_SIZE = 12

# Dados e afinações de voz individuais de cada personagem
const NUMBER_DATA = {
	1: { "name": "Um", "phrase": "Um! Tão curiosa!", "freq": 330.0, "pitch": 1.45, "intro": "Sou o Um!" },
	2: { "name": "Dois", "phrase": "Dois! Um par de óculos!", "freq": 293.66, "pitch": 1.3, "intro": "Sou o Dois! Um par!" },
	3: { "name": "Três", "phrase": "Três! Hora do show!", "freq": 329.63, "pitch": 1.2, "intro": "Sou o Três! Malabarista!" },
	4: { "name": "Quatro", "phrase": "Quatro! Eu sou um quadrado!", "freq": 261.63, "pitch": 1.0, "intro": "Sou o Quatro! Um quadrado!" },
	5: { "name": "Cinco", "phrase": "Cinco! Dá cinco aqui!", "freq": 392.00, "pitch": 1.15, "intro": "Sou o Cinco! Toca aqui!" },
	6: { "name": "Seis", "phrase": "Seis! Vamos jogar!", "freq": 440.00, "pitch": 1.05, "intro": "Sou o Seis! Jogo de dados!" },
	7: { "name": "Sete", "phrase": "Sete! Eu sou o Arco-Íris!", "freq": 493.88, "pitch": 1.1, "intro": "Sou o Sete! O arco-íris!" },
	8: { "name": "Oito", "phrase": "Oito! Octobloco ao resgate!", "freq": 220.0, "pitch": 0.85, "intro": "Sou o Oito! Octobloco!" },
	9: { "name": "Nove", "phrase": "Nove! Três vezes três!", "freq": 349.23, "pitch": 0.95, "intro": "Sou o Nove! Três vezes três!" },
	10: { "name": "Dez", "phrase": "Dez! Foguete decolando!", "freq": 523.25, "pitch": 1.1, "intro": "Sou o Dez! Foguete espacial!" }
}

# Falas pedagógicas do narrador e dos personagens
const OPERATION_VOICES = {
	"1 + 1 = 2": { "text": "Um mais um é igual a Dois!", "num": 2 },
	"2 + 1 = 3": { "text": "Dois mais um é igual a Três! Hummm, maçã!", "num": 3 },
	"3 + 1 = 4": { "text": "Três mais um é igual a Quatro!", "num": 4 },
	"3 + 2 = 5": { "text": "Três mais dois é igual a Cinco! Toca aqui!", "num": 5 },
	"4 + 3 = 7": { "text": "Quatro mais três é igual a Sete! As cores do arco-íris!", "num": 7 },
	"8 - 2 = 6": { "text": "Oito menos dois é igual a Seis!", "num": 6 },
	"9 - 1 = 8": { "text": "Atchim! Nove menos um é igual a Oito!", "num": 8 },
	"8 - 1 = 7": { "text": "Atchim! Oito menos um é igual a Sete!", "num": 7 },
	"7 - 1 = 6": { "text": "Atchim! Sete menos um é igual a Seis!", "num": 6 },
	"4 + 4 + 2 = 10": { "text": "Quatro mais quatro mais dois é igual a Dez! Preparar para decolar!", "num": 10 }
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in range(POOL_SIZE):
		var p = AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		audio_players.append(p)

func _get_free_player() -> AudioStreamPlayer:
	for p in audio_players:
		if not p.playing:
			return p
	return audio_players[0]

# Narrador por voz (TTS do aparelho, offline). A criança escuta em vez de ler.
var _tts_voice: String = ""
var _tts_checked: bool = false

func _find_voice() -> void:
	_tts_checked = true
	if not DisplayServer.has_feature(DisplayServer.FEATURE_TEXT_TO_SPEECH):
		return
	for lang in ["pt_BR", "pt-BR", "pt"]:
		var voices = DisplayServer.tts_get_voices_for_language(lang)
		if voices.size() > 0:
			_tts_voice = voices[0]
			return

func speak(text: String) -> void:
	if text.strip_edges() == "":
		return
	if not _tts_checked:
		_find_voice()
	if _tts_voice != "":
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(text, _tts_voice, 100, 1.15, 0.9, 0, true)
	else:
		# Fallback autônomo e musical caso o aparelho não tenha motor de fala instalado:
		# toca uma entonação alegre e expressiva correspondente à frase!
		_play_sentence_cadence(text)

func stop_speaking() -> void:
	if DisplayServer.has_feature(DisplayServer.FEATURE_TEXT_TO_SPEECH):
		DisplayServer.tts_stop()

# Toca cadência melódica lúdica simulando fala (estilo linguagem encantada/minion)
func _play_sentence_cadence(text: String) -> void:
	var syllables = maxi(3, mini(8, text.split(" ").size() * 2))
	var freqs = [329.63, 392.00, 440.00, 523.25, 587.33]
	for i in range(syllables):
		var f = freqs[(i * 2 + text.length()) % freqs.size()]
		get_tree().create_timer(i * 0.11).timeout.connect(func():
			_play_single_freq(f, 0.14)
		)

# Fala de apresentação do personagem ao tocar no Numberling acima da cabeça: "Sou o [Número]!"
func play_character_intro(num: int) -> void:
	var data = NUMBER_DATA.get(num, { "name": str(num), "intro": "Sou o %d!" % num, "pitch": 1.0 })
	
	# 1. Tenta carregar arquivo específico (ex: res://Assets/Audio/sou_o_1.ogg ou voz_1.ogg)
	var possible_paths = [
		"res://Assets/Audio/sou_o_%d.ogg" % num,
		"res://Assets/Audio/voz_%d.ogg" % num,
		"res://Assets/Audio/char_%d.ogg" % num
	]
	for path in possible_paths:
		if ResourceLoader.exists(path):
			var stream = load(path)
			var p = _get_free_player()
			p.stream = stream
			p.pitch_scale = data.pitch
			p.play()
			return
			
	# 2. Caso não exista o arquivo, toca entonação melódica de fala com o pitch do personagem
	_play_voice_cadence(num, data.pitch)

# Toca narração pedagógica de uma operação matemática
func play_operation_narrator(op_key: String) -> String:
	var op_info = OPERATION_VOICES.get(op_key, { "text": op_key, "num": 1 })
	var text = op_info.text
	var target_num = op_info.num
	
	# Verifica se há arquivo de áudio para a operação
	var safe_key = op_key.replace(" ", "").replace("+", "mais").replace("-", "menos").replace("=", "igual")
	var possible_path = "res://Assets/Audio/op_%s.ogg" % safe_key
	if ResourceLoader.exists(possible_path):
		var stream = load(possible_path)
		var p = _get_free_player()
		p.stream = stream
		p.pitch_scale = 1.0
		p.play()
	else:
		# Toca sequência musical festiva e o jingle do número resultante
		play_number_sound(target_num)
		
	return text

# Fala amigável e sem punição: "Opa, fiquei muito grande!"
func play_oops_too_big() -> void:
	var path = "res://Assets/Audio/opa_muito_grande.ogg"
	if ResourceLoader.exists(path):
		var stream = load(path)
		var p = _get_free_player()
		p.stream = stream
		p.pitch_scale = 1.0
		p.play()
		return
	_play_oops_synth()

# Som de espirro cômico para a fase do 9
func play_sneeze_sound() -> void:
	var path = "res://Assets/Audio/atchim.ogg"
	if ResourceLoader.exists(path):
		var stream = load(path)
		var p = _get_free_player()
		p.stream = stream
		p.play()
		return
	_play_sneeze_synth()

# Toca o som característico de um número recém-formado com jingle exclusivo
func play_number_sound(num: int) -> void:
	var char_data = NUMBER_DATA.get(num, { "name": str(num), "phrase": str(num), "freq": 440.0, "pitch": 1.0 })
	
	var possible_paths = [
		"res://Assets/Audio/num_%d.ogg" % num,
		"res://Assets/Audio/%d.ogg" % num,
		"res://Assets/Audio/%s.ogg" % char_data.name.to_lower()
	]
	
	for path in possible_paths:
		if ResourceLoader.exists(path):
			var stream = load(path)
			var p = _get_free_player()
			p.stream = stream
			p.pitch_scale = 1.0
			p.play()
			return
			
	match num:
		4:
			_play_square_jingle()
		7:
			_play_rainbow_arpeggio()
		8:
			_play_octoblock_fanfare()
		10:
			_play_rocket_launch()
		_:
			play_synth_note(num)

func _play_square_jingle() -> void:
	var base_freq = 349.23
	for i in range(4):
		get_tree().create_timer(i * 0.09).timeout.connect(func():
			_play_single_freq(base_freq, 0.12)
		)

func _play_rainbow_arpeggio() -> void:
	var rainbow_notes = [261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88]
	for i in range(rainbow_notes.size()):
		get_tree().create_timer(i * 0.08).timeout.connect(func():
			_play_single_freq(rainbow_notes[i], 0.22)
		)

func _play_octoblock_fanfare() -> void:
	var hero_notes = [392.0, 392.0, 523.25, 659.25]
	var delays = [0.0, 0.1, 0.22, 0.38]
	for i in range(hero_notes.size()):
		get_tree().create_timer(delays[i]).timeout.connect(func():
			_play_single_freq(hero_notes[i], 0.3)
		)

func _play_rocket_launch() -> void:
	var p = _get_free_player()
	var sample_rate = 22050
	var duration = 0.7
	var num_samples = int(sample_rate * duration)
	var wav_data = PackedByteArray()
	wav_data.resize(num_samples * 2)
	for i in range(num_samples):
		var t = float(i) / float(sample_rate)
		var freq = lerp(180.0, 950.0, t / duration)
		var env = sin(PI * (t / duration))
		var noise = randf_range(-0.3, 0.3)
		var sample = (sin(TAU * freq * t) * 0.65 + noise * 0.35) * env
		var val_16 = int(clamp(sample, -1.0, 1.0) * 32767.0)
		wav_data.encode_s16(i * 2, val_16)
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = wav_data
	p.stream = stream
	p.play()

# Cadência de fala sintetizada: "Sou o [Número]!"
func _play_voice_cadence(num: int, pitch: float) -> void:
	var base = 280.0 * pitch
	var notes = [base, base * 1.25, base * 1.5]
	for i in range(notes.size()):
		get_tree().create_timer(i * 0.09).timeout.connect(func():
			_play_single_freq(notes[i], 0.16)
		)

# Efeito cômico "Opa!"
func _play_oops_synth() -> void:
	var notes = [380.0, 260.0]
	for i in range(notes.size()):
		get_tree().create_timer(i * 0.12).timeout.connect(func():
			_play_single_freq(notes[i], 0.2)
		)

# Síntese do espirro ("Atchim!")
func _play_sneeze_synth() -> void:
	var p = _get_free_player()
	var sample_rate = 22050
	var duration = 0.3
	var num_samples = int(sample_rate * duration)
	var wav_data = PackedByteArray()
	wav_data.resize(num_samples * 2)
	for i in range(num_samples):
		var t = float(i) / float(sample_rate)
		var env = exp(-t * 9.0)
		var noise = randf_range(-0.6, 0.6)
		var sample = (sin(TAU * 520.0 * t) * 0.4 + noise * 0.6) * env
		wav_data.encode_s16(i * 2, int(clamp(sample, -1.0, 1.0) * 32767.0))
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = wav_data
	p.stream = stream
	p.play()

# Síntese em tempo real de uma nota brilhante/marimba
func play_synth_note(num: int) -> void:
	var char_data = NUMBER_DATA.get(num, { "freq": 440.0, "pitch": 1.0 })
	var base_freq = char_data.freq
	var sample_rate = 22050
	var duration = 0.45
	var num_samples = int(sample_rate * duration)
	
	var wav_data = PackedByteArray()
	wav_data.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t = float(i) / float(sample_rate)
		var env = exp(-t * 6.5)
		var sample = (sin(TAU * base_freq * t) * 0.7 + sin(TAU * base_freq * 2.0 * t) * 0.25 + sin(TAU * base_freq * 3.0 * t) * 0.1) * env
		sample = clamp(sample, -1.0, 1.0)
		wav_data.encode_s16(i * 2, int(sample * 32767.0))
		
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = wav_data
	
	var p = _get_free_player()
	p.stream = stream
	p.pitch_scale = 1.0
	p.play()

# Som animado de fusão ("Pop / Plop" brilhante)
func play_merge_sound() -> void:
	_play_procedural_pop(1.2)

# Som de corte/divisão ("Whoosh / Slice")
func play_split_sound() -> void:
	_play_procedural_whoosh()

# Som de clique de botão da interface
func play_click_sound() -> void:
	_play_procedural_pop(1.8)

# Fanfarra de vitória
func play_victory_sound() -> void:
	var notes = [261.63, 329.63, 392.0, 523.25]
	for i in range(notes.size()):
		get_tree().create_timer(i * 0.13).timeout.connect(func():
			_play_single_freq(notes[i], 0.35)
		)

func _play_single_freq(freq: float, duration: float) -> void:
	var sample_rate = 22050
	var num_samples = int(sample_rate * duration)
	var wav_data = PackedByteArray()
	wav_data.resize(num_samples * 2)
	for i in range(num_samples):
		var t = float(i) / float(sample_rate)
		var env = exp(-t * 4.0)
		var sample = (sin(TAU * freq * t) * 0.8 + sin(TAU * freq * 2.0 * t) * 0.2) * env
		var val_16 = int(clamp(sample, -1.0, 1.0) * 32767.0)
		wav_data.encode_s16(i * 2, val_16)
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = wav_data
	var p = _get_free_player()
	p.stream = stream
	p.play()

func _play_procedural_pop(pitch_mult: float = 1.0) -> void:
	var sample_rate = 22050
	var duration = 0.15
	var num_samples = int(sample_rate * duration)
	var wav_data = PackedByteArray()
	wav_data.resize(num_samples * 2)
	for i in range(num_samples):
		var t = float(i) / float(sample_rate)
		var freq = lerp(450.0 * pitch_mult, 150.0 * pitch_mult, t / duration)
		var env = (1.0 - t / duration) * exp(-t * 12.0)
		var sample = sin(TAU * freq * t) * env
		var val_16 = int(clamp(sample, -1.0, 1.0) * 32767.0)
		wav_data.encode_s16(i * 2, val_16)
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = wav_data
	var p = _get_free_player()
	p.stream = stream
	p.play()

func _play_procedural_whoosh() -> void:
	var sample_rate = 22050
	var duration = 0.2
	var num_samples = int(sample_rate * duration)
	var wav_data = PackedByteArray()
	wav_data.resize(num_samples * 2)
	for i in range(num_samples):
		var t = float(i) / float(sample_rate)
		var freq = lerp(800.0, 200.0, t / duration)
		var env = sin(PI * (t / duration)) * 0.7
		var noise = randf_range(-0.3, 0.3)
		var sample = (sin(TAU * freq * t) * 0.7 + noise * 0.3) * env
		var val_16 = int(clamp(sample, -1.0, 1.0) * 32767.0)
		wav_data.encode_s16(i * 2, val_16)
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = wav_data
	var p = _get_free_player()
	p.stream = stream
	p.play()
