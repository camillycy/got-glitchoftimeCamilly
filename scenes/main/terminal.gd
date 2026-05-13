extends Node2D

var player_near = false

@onready var puzzle = $"../WireMiniGame"

signal puzzle_completed

func _ready():
	puzzle.puzzle_completed.connect(_on_puzzle_completed)


func _process(delta):

	if player_near:
		print("PERTO DO TERMINAL")

	if Input.is_action_just_pressed("interact_cientista"):
		print("APERTOU CTRL")

	if player_near and Input.is_action_just_pressed("interact_cientista"):
		print("ABRINDO PUZZLE")
		puzzle.visible = true


func _on_area_2d_body_entered(body):
	print("ENTROU:", body.name)

	if body.name == "Cientista":
		player_near = true
		print("PLAYER DETECTADO")


func _on_area_2d_body_exited(body):
	if body.name == "Cientista":
		player_near = false


func _on_puzzle_completed():

	puzzle.visible = false

	$TerminalEstragado.visible = false
	$TerminalFixed.visible = true

	print("Terminal consertado")
