extends Node2D

@onready var intro_lab = $IntroLab
@onready var guardian_scene = $GuardianScene
@onready var guardian = $GuardianScene/PastWorld/Guardian
@onready var scientist = $IntroLab/FutureWorld/CharacterBody2D/Scientist

@onready var black_fade = $CanvasLayer/BlackFade
@onready var white_flash = $CanvasLayer/WhiteFlash
@onready var dialogue = $CanvasLayer/DialogueText

@onready var middle = $CanvasLayer/Middle
@onready var split_top = $CanvasLayer/WhiteSplitTop
@onready var split_bottom = $CanvasLayer/WhiteSplitBottom


func _ready():

	# ordem visual da UI
	black_fade.z_index = 1
	white_flash.z_index = 2

	middle.z_index = 3
	split_top.z_index = 3
	split_bottom.z_index = 3

	dialogue.z_index = 999

	# estado inicial
	guardian_scene.visible = false

	black_fade.visible = false
	white_flash.visible = false

	split_top.visible = false
	split_bottom.visible = false
	middle.visible = false

	dialogue.visible = false

	scientist.play("idle")

	start_intro()


func start_intro() -> void:

	# -------------------
	# CIENTISTA FALANDO
	# -------------------

	await speak("Com isso...", 2.0)

	await speak(
		"O presente deve finalmente se estabilizar.",
		3.0
	)

	await speak("Chega de guerras.", 2.0)

	await speak("Chega de destruição.", 2.0)

	await speak(
		"Só preciso ativar o terminal...",
		2.5
	)

	# pausa dramática
	dialogue.visible = false
	await get_tree().create_timer(1.5).timeout

	await speak("Vamos lá...", 1.2)

	dialogue.visible = false

	# tempo dela mexendo no terminal
	await get_tree().create_timer(2.0).timeout

	# -------------------
	# TERMINAL BUGA
	# -------------------

	await terminal_error()

	# -------------------
	# GUARDIÃO ENTRA
	# -------------------

	intro_lab.visible = false
	guardian_scene.visible = true

	await guardian_intro()

	# -------------------
	# GUARDIÃO TREMENDO
	# -------------------

	await shake_guardian_scene()

	# -------------------
	# TELA PRETA
	# -------------------

	guardian_scene.visible = false

	black_fade.visible = true
	black_fade.modulate.a = 1.0

	await speak(
		"Algo deu errado no experimento.",
		3.0
	)

	dialogue.visible = false

	# -------------------
	# SPLIT TEMPORAL
	# -------------------

	await white_split_effect()

	# -------------------
	# FINAL
	# -------------------

	black_fade.visible = true
	black_fade.modulate.a = 1.0

	dialogue.visible = true

	await speak(
		"Suas ações afetam o outro.",
		2.5
	)

	await speak(
		"Se ajudem até o final...",
		2.0
	)

	await speak(
		"...e estabilizem o espaço-tempo.",
		3.0
	)

	# some diálogo
	dialogue.visible = false

	# garante preto total
	black_fade.visible = true
	black_fade.modulate.a = 1.0

	# pausa dramática
	await get_tree().create_timer(1.5).timeout

	# muda sozinho pra fase 0
	get_tree().change_scene_to_file(
		"res://scenes/main/fase_0.tscn"
	)


func speak(texto: String, tempo: float):

	dialogue.visible = true
	dialogue.text = texto

	await get_tree().create_timer(tempo).timeout


func terminal_error():

	white_flash.visible = true

	for i in range(8):

		white_flash.modulate.a = 0.15

		await get_tree().create_timer(0.08).timeout

		white_flash.modulate.a = 0.0

		await get_tree().create_timer(0.08).timeout

	# flash forte
	white_flash.modulate.a = 1.0

	await get_tree().create_timer(0.2).timeout

	white_flash.modulate.a = 0.0
	white_flash.visible = false


func guardian_intro():

	# começa fora da tela
	guardian.position.x = -120

	# animação andando
	guardian.play("walking")

	# anda até o centro
	var tween = create_tween()

	tween.tween_property(
		guardian,
		"position:x",
		540,
		2.2
	)

	await tween.finished

	# para no centro
	guardian.play("default")

	# suspense antes do caos
	await get_tree().create_timer(0.8).timeout


func shake_guardian_scene():

	# dura mais tempo
	for i in range(120):

		guardian_scene.position = Vector2(
			randf_range(-5, 5),
			randf_range(-5, 5)
		)

		await get_tree().create_timer(0.04).timeout

	guardian_scene.position = Vector2.ZERO


func white_split_effect():

	# COMEÇAM JUNTAS
	var center_y := 280.0

	split_top.position = Vector2(120, center_y)
	split_bottom.position = Vector2(120, center_y)

	black_fade.visible = true
	black_fade.modulate.a = 1.0

	split_top.visible = false
	split_bottom.visible = false

	# piscando no meio
	split_top.visible = true
	split_bottom.visible = true

	for i in range(6):

		split_top.visible = false
		split_bottom.visible = false

		await get_tree().create_timer(0.08).timeout

		split_top.visible = true
		split_bottom.visible = true

		await get_tree().create_timer(0.08).timeout

	# glitch
	for i in range(20):

		var glitch_x = 120 + randf_range(-8, 8)

		split_top.position.x = glitch_x
		split_bottom.position.x = glitch_x

		await get_tree().create_timer(0.04).timeout

	split_top.position.x = 120
	split_bottom.position.x = 120

	# BUM abre rápido
	var tween = create_tween()

	tween.parallel().tween_property(
		split_top,
		"position:y",
		140,
		0.25
	)

	tween.parallel().tween_property(
		split_bottom,
		"position:y",
		430,
		0.25
	)

	await tween.finished

	# piscando lento
	var blink_speeds = [
		0.10,
		0.18,
		0.28,
		0.40,
		0.55,
		0.75,
		1.0
	]

	for speed in blink_speeds:

		split_top.visible = false
		split_bottom.visible = false

		await get_tree().create_timer(speed).timeout

		split_top.visible = true
		split_bottom.visible = true

		await get_tree().create_timer(speed).timeout

	await get_tree().create_timer(1.0).timeout

	split_top.visible = false
	split_bottom.visible = false
