extends Node2D

# ─── REFERÊNCIAS ──────────────────────────────────────────────────────────────
@onready var anim            = $AnimationPlayer
@onready var audio           = $AudioStreamPlayer
@onready var timer           = $Timer

# UI
@onready var black_fade      = $CanvasLayer/BlackFade
@onready var white_flash     = $CanvasLayer/WhiteFlash
@onready var dialogue_text   = $CanvasLayer/DialogueText
@onready var divider         = $CanvasLayer/Divider
@onready var split_screen    = $CanvasLayer/SplitScreen

# Passado
@onready var past_world      = $CanvasLayer/SplitScreen/PastWorld
@onready var guardian        = $CanvasLayer/SplitScreen/PastWorld/Guardian
@onready var past_glitch     = $CanvasLayer/SplitScreen/PastWorld/PastGlitch
@onready var past_particles  = $CanvasLayer/SplitScreen/PastWorld/PastParticles

# Futuro
@onready var future_world    = $CanvasLayer/SplitScreen/FutureWorld
@onready var scientist       = $CanvasLayer/SplitScreen/FutureWorld/Scientist
@onready var terminal_screen = $CanvasLayer/SplitScreen/FutureWorld/TerminalScreen
@onready var terminal_glow   = $CanvasLayer/SplitScreen/FutureWorld/TerminalGlow
@onready var future_glitch   = $CanvasLayer/SplitScreen/FutureWorld/FutureGlitch
@onready var lab_particles   = $CanvasLayer/SplitScreen/FutureWorld/LabParticles

# ─── ESTADO ───────────────────────────────────────────────────────────────────
var _glitch_timer   : float = 0.0
var _glitch_active  : bool  = false
var _terminal_timer : float = 0.0
var _fase           : int   = 0   # 0=lab  1=flash  2=preto  3=split  4=fim

# ─── CONFIGURAÇÕES ────────────────────────────────────────────────────────────
const FADE_SPEED       = 1.2
const GLITCH_INTERVAL  = 0.18
const TERMINAL_BLINK   = 0.4

# ─── INIT ─────────────────────────────────────────────────────────────────────
func _ready() -> void:
	_setup_initial_state()
	_start_intro()

func _setup_initial_state() -> void:
	# começa tudo escuro
	black_fade.color   = Color(0, 0, 0, 1)
	white_flash.color  = Color(1, 1, 1, 0)
	dialogue_text.text = ""
	dialogue_text.modulate.a = 0.0

	# split screen começa invisível
	divider.modulate.a      = 0.0
	past_world.modulate.a   = 0.0
	future_world.modulate.a = 0.0

	# glitch começa invisível
	past_glitch.modulate.a   = 0.0
	future_glitch.modulate.a = 0.0

	# partículas pausadas até o split
	past_particles.emitting  = false
	lab_particles.emitting   = false

# ─── SEQUÊNCIA PRINCIPAL ──────────────────────────────────────────────────────
func _start_intro() -> void:
	await _fade_out_black(1.5)          # ➊ FADE IN: revela laboratório
	_fase = 0
	scientist.play("typing")            # cientista mexendo no terminal

	await _wait(3.0)                    # laboratório visível por 3s

	await _terminal_failure()           # ➋ luzes piscam, terminal falha

	await _wait(0.3)

	await _white_flash_in()             # ➌ FLASH branco

	await _fade_in_black(0.1)           # ➍ corta pra preto imediato
	white_flash.color.a = 0.0

	_fase = 2
	await _show_dialogue("Algo deu errado no experimento.", 2.5)

	await _wait(1.0)

	await _fade_out_dialogue()

	await _reveal_split_screen()        # ➎ split screen aparece

	_fase = 3
	past_particles.emitting = true
	lab_particles.emitting  = true
	guardian.play("idle")
	scientist.play("looking")

	await _wait(1.5)

	await _do_glitch_sequence()         # ➏ ambos glitcham e olham

	await _show_dialogue("Suas ações afetam o outro.", 3.0)

	await _wait(1.5)

	await _fade_in_black(1.0)           # ➐ fade out final

	_fase = 4
	_end_intro()

# ─── FUNÇÕES DE EFEITO ────────────────────────────────────────────────────────

func _fade_out_black(duration: float) -> void:
	var t = 0.0
	while t < duration:
		t += get_process_delta_time()
		black_fade.color.a = lerp(1.0, 0.0, t / duration)
		await get_tree().process_frame
	black_fade.color.a = 0.0

func _fade_in_black(duration: float) -> void:
	var t = 0.0
	while t < duration:
		t += get_process_delta_time()
		black_fade.color.a = lerp(0.0, 1.0, t / duration)
		await get_tree().process_frame
	black_fade.color.a = 1.0

func _white_flash_in() -> void:
	# flash rápido: sobe e desce
	var t = 0.0
	while t < 0.15:
		t += get_process_delta_time()
		white_flash.color.a = lerp(0.0, 1.0, t / 0.15)
		await get_tree().process_frame
	# mantém por um frame
	await get_tree().process_frame

func _terminal_failure() -> void:
	# terminal pisca 4x e depois tela fica vermelha antes do flash
	for i in range(4):
		terminal_screen.modulate = Color(1, 0.2, 0.2, 1)
		terminal_glow.color      = Color(1, 0.1, 0.1, 0.8)
		await _wait(0.12)
		terminal_screen.modulate = Color(0.2, 1, 0.4, 1)
		terminal_glow.color      = Color(0.2, 1, 0.4, 0.6)
		await _wait(0.12)

	# shake da câmera
	await _camera_shake(0.4, 6.0)

	# flash no terminal
	terminal_screen.modulate = Color(1, 1, 1, 1)
	terminal_glow.color      = Color(1, 1, 1, 1.0)
	terminal_glow.energy     = 3.0

func _camera_shake(duration: float, strength: float) -> void:
	var cam : Camera2D = $Camera2D
	var original       = cam.position
	var t              = 0.0
	while t < duration:
		t += get_process_delta_time()
		cam.position = original + Vector2(
			randf_range(-strength, strength),
			randf_range(-strength, strength)
		)
		await get_tree().process_frame
	cam.position = original

func _show_dialogue(txt: String, duration: float) -> void:
	dialogue_text.text = txt
	# fade in do texto
	var t = 0.0
	while t < 0.6:
		t += get_process_delta_time()
		dialogue_text.modulate.a = lerp(0.0, 1.0, t / 0.6)
		await get_tree().process_frame
	await _wait(duration)

func _fade_out_dialogue() -> void:
	var t = 0.0
	while t < 0.5:
		t += get_process_delta_time()
		dialogue_text.modulate.a = lerp(1.0, 0.0, t / 0.5)
		await get_tree().process_frame
	dialogue_text.modulate.a = 0.0
	dialogue_text.text = ""

func _reveal_split_screen() -> void:
	# fade out do preto, divide e revela os dois mundos
	var t = 0.0
	while t < 1.2:
		t += get_process_delta_time()
		var p = t / 1.2
		black_fade.color.a      = lerp(1.0, 0.0, p)
		divider.modulate.a      = lerp(0.0, 1.0, p)
		past_world.modulate.a   = lerp(0.0, 1.0, p)
		future_world.modulate.a = lerp(0.0, 1.0, p)
		await get_tree().process_frame

func _do_glitch_sequence() -> void:
	# glitch alternado nos dois lados por ~1.5s
	for i in range(8):
		var show_past   = (i % 2 == 0)
		past_glitch.modulate.a   = 1.0 if show_past else 0.0
		future_glitch.modulate.a = 0.0 if show_past else 1.0

		# offset aleatório pra dar efeito de deslocamento
		past_glitch.position.x   = randf_range(-8, 8)
		future_glitch.position.x = randf_range(-8, 8)

		await _wait(GLITCH_INTERVAL)

	# limpa
	past_glitch.modulate.a   = 0.0
	future_glitch.modulate.a = 0.0

	# personagens "olham" — troca de animação
	guardian.play("look_right")
	scientist.play("look_left")

	await _wait(1.0)

# ─── FIM ──────────────────────────────────────────────────────────────────────
func _end_intro() -> void:
	# troca pra cena de gameplay
	get_tree().change_scene_to_file("res://scenes/main/MainScene.tscn")

# ─── UTILITÁRIO ───────────────────────────────────────────────────────────────
func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
